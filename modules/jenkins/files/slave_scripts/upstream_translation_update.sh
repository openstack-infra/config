#!/bin/bash -xe

PROJECT=$1

if [ ! `echo $ZUUL_REFNAME | grep master` ]
then
    exit 0
fi

# initialize transifex client
tx init --host=https://www.transifex.com
tx set --auto-local -r ${PROJECT}.${PROJECT}-translations "${PROJECT}/locale/<lang>/LC_MESSAGES/${PROJECT}.po" --source-lang en --source-file ${PROJECT}/locale/${PROJECT}.pot -t PO --execute

# Pull all upstream translations
tx pull -a
# Update the .pot file
python setup.py extract_messages
PO_FILES=`find ${PROJECT}/locale -name '*.po'`
if [ -n "$PO_FILES" ]
then
    # Use updated .pot file to update translations
    python setup.py update_catalog
fi

if [ ! `git diff --quiet` ]
then
    # Push .pot changes to transifex
    tx --debug --traceback push -s
    # Push translation changes to transifex
    # Disable -e as we can live with failed translation pushes (failures
    # occur when a translation file has no translations in it not really
    # error worthy but they occur)
    set +e
    tx --debug --traceback push -t --skip
    set -e
fi
