#!/bin/bash -xe

# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

ORG=$1
PROJECT=$2
COMMIT_MSG="Imported Translations from Transifex"

git config user.name "OpenStack Proposal Bot"
git config user.email "openstack-infra@lists.openstack.org"
git config gitreview.username "proposal-bot"

git review -s

# See if there is an open change in the transifex/translations topic
# If so, get the change id for the existing change for use in the commit msg.
change_info=`ssh -p 29418 proposal-bot@review.openstack.org gerrit query --current-patch-set status:open project:$ORG/$PROJECT topic:transifex/translations owner:proposal-bot`
previous=`echo "$change_info" | grep "^  number:" | awk '{print $2}'`
if [ "x${previous}" != "x" ] ; then
    change_id=`echo "$change_info" | grep "^change" | awk '{print $2}'`
    # read return a non zero value when it reaches EOF. Because we use a
    # heredoc here it will always reach EOF and return a nonzero value.
    # Disable -e temporarily to get around the read.
    set +e
    read -d '' COMMIT_MSG <<EOF
Imported Translations from Transifex

Change-Id: $change_id
EOF
    set -e
fi

# Initialize the transifex client, if there's no .tx directory
if [ ! -d .tx ] ; then
    tx init --host=https://www.transifex.com
fi

# User visible strings
tx set --auto-local -r ${PROJECT}.${PROJECT}-translations "${PROJECT}/locale/<lang>/LC_MESSAGES/${PROJECT}.po" --source-lang en --source-file ${PROJECT}/locale/${PROJECT}.pot -t PO --execute

# Strings for various log levels
LEVELS="info warning error critical"
# Keywords for each log level:
declare -A LKEYWORD
LKEYWORD['info']='_LI'
LKEYWORD['warning']='_LW'
LKEYWORD['error']='_LE'
LKEYWORD['critical']='_LC'

for level in $LEVELS ; do
  # Bootstrapping: Create file if it does not exist yet, otherwise "tx
  # set" will fail
  if [ ! -e  ${PROJECT}/locale/${PROJECT}-log-${level}.pot ]
  then
    touch ${PROJECT}/locale/${PROJECT}-log-${level}.pot
  fi
  tx set --auto-local -r ${PROJECT}.${PROJECT}-log-${level}-translations \
    "${PROJECT}/locale/<lang>/LC_MESSAGES/${PROJECT}.po-log-${level}" \
    --source-lang en \
    --source-file ${PROJECT}/locale/${PROJECT}-log-${level}.pot -t PO \
    --execute
done

# Pull upstream translations of files that are at least 75 %
# translated
tx pull -a -f --minimum-perc=75

# Update the .pot files
python setup.py extract_messages
for level in $LEVELS ; do
  python setup.py extract_messages --no-default-keywords \
    --keyword ${LKEYWORD[$level]} \
    --output-file ${PROJECT}/locale/${PROJECT}-log-${level}.pot
done

PO_FILES=`find ${PROJECT}/locale -name "${PROJECT}.po"`
if [ -n "$PO_FILES" ]
then
    # Use updated .pot file to update translations
    python setup.py update_catalog --no-fuzzy-matching  --ignore-obsolete=true
fi
for level in $LEVELS ; do
  PO_FILES=`find ${PROJECT}/locale -name "${PROJECT}-log-${level}.po"`
  if [ -n "$PO_FILES" ]
  then
    python setup.py update_catalog --no-fuzzy-matching \
        --ignore-obsolete=true --domain=${PROJECT}-log-${level}
  fi
done

# Add all changed files to git
git add $PROJECT/locale/*

# Don't send files where the only things which have changed are the
# creation date, the version number, the revision date, or comment
# lines.
for f in `git diff --cached --name-only`
do
  if [ `git diff --cached $f |egrep -v "(POT-Creation-Date|Project-Id-Version|PO-Revision-Date|^\+{3}|^\-{3}|^[-+]#)" | egrep -c "^[\-\+]"` -eq 0 ]
  then
      git reset -q $f
      git checkout -- $f
  fi
done

# Don't send a review if nothing has changed.
if [ `git diff --cached |wc -l` -gt 0 ]
then
    # Commit and review
    git commit -F- <<EOF
$COMMIT_MSG
EOF
    git review -t transifex/translations
fi
