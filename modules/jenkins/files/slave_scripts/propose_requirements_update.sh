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

INITIAL_COMMIT_MSG="Updated from global requirements"
TOPIC="openstack/requirements"
USERNAME=${USERNAME:-$USER}
# Find the branch. This require a bit of string processing.
# 1. remove the first 2 bytes that git provides as a list prefix.
# 2. remove any refs that refer to other branches like HEAD.
# 3. get the basename of each name to remove the refs/remotes/* prefixes.
# 4. take the head of the list as we can currently only deal with one branch.
BRANCH=$(git branch --no-color --contains $ZUUL_NEWREV | cut -b3- | grep -v -- '->' | xargs -n1 basename | head -1)

git config user.name "OpenStack Jenkins"
git config user.email "jenkins@openstack.org"
git config gitreview.username $USERNAME

for PROJECT in $(cat projects.txt); do

    # See if there is an open change in the openstack/requirements topic
    # If so, get the change id for the existing change for use in the
    # commit msg.
    change_info=$(ssh -p 29418 review.openstack.org gerrit query --current-patch-set status:open project:$PROJECT topic:$TOPIC owner:$USERNAME branch:$BRANCH)
    previous=$(echo "$change_info" | grep "^  number:" | awk '{print $2}')
    if [ "x${previous}" != "x" ] ; then
        change_id=$(echo "$change_info" | grep "^change" | awk '{print $2}')
        # read return a non zero value when it reaches EOF. Because we use a
        # heredoc here it will always reach EOF and return a nonzero value.
        # Disable -e temporarily to get around the read.
        # The reason we use read is to allow for multiline variable content
        # and variable interpolation. Simply double quoting a string across
        # multiple lines removes the newlines.
        set +e
        read -d '' COMMIT_MSG <<EOF
$INITIAL_COMMIT_MSG

Change-Id: $change_id
EOF
        set -e
    else
        COMMIT_MSG=$INITIAL_COMMIT_MSG
    fi

    rm -rf $(basename $PROJECT)
    git clone --depth=1 ssh://$USERNAME@review.openstack.org:29418/$PROJECT.git

    PROJECT_DIR=$(basename $PROJECT)
    python update.py $PROJECT_DIR

    pushd $PROJECT_DIR
    git review -s

    if ! git diff --quiet ; then
        # Commit and review
        git commit -a -F- <<EOF
$COMMIT_MSG
EOF
        git review -t $TOPIC $BRANCH
    fi
    popd

done
