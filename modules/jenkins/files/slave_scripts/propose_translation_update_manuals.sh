#!/bin/bash -xe

PROJECT="openstack-manuals"
DocNameList="basic-install cli-guide common openstack-block-storage-admin openstack-compute-admin openstack-ha openstack-install openstack-network-connectivity-admin openstack-object-storage-admin openstack-ops"

COMMIT_MSG="Imported Translations from Transifex"

git config user.name "OpenStack Jenkins"
git config user.email "jenkins@openstack.org"
git config gitreview.username "jenkins"

git review -s

# See if there is an open change in the transifex/translations topic
# If so, get the change id for the existing change for use in the commit msg.
change_info=`ssh -p 29418 review.openstack.org gerrit query --current-patch-set status:open project:openstack/$PROJECT topic:transifex/translations owner:jenkins`
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

# no need to initialize transifex client, because there is a .tx folder in openstack-manuals
# tx init --host=https://www.transifex.com

# generate pot one by one
for DOCNAME in ${DocNameList}
do
    tx set --auto-local -r openstack-manuals-i18n.${DOCNAME} "doc/src/docbkx/${DOCNAME}/locale/<lang>.po" --source-lang en --source-file doc/src/docbkx/${DOCNAME}/locale/${DOCNAME}.pot -t PO --execute
    # openstack-ha needs to create new DocBook files
    if [ "$DOCNAME" == "openstack-ha" ]
    then
        asciidoc -b docbook -d book -o - doc/src/docbkx/openstack-ha/ha-guide.txt |  xsltproc -o - /usr/share/xml/docbook/stylesheet/docbook5/db4-upgrade.xsl - | xmllint  --format - | sed -e 's,<book,<book xml:id="bk-ha-guide",' | sed -e 's,<info,<?rax pdf.url="../openstack-ha-guide-trunk.pdf"?><info,' > doc/src/docbkx/openstack-ha/bk-ha-guide.xml
    fi
    # Update the .pot file
    ./tools/generatepot ${DOCNAME}
    # Add all changed files to git
    git add doc/src/docbkx/${DOCNAME}/locale/*
done

if [ ! `git diff-index --quiet HEAD --` ]
then
    # Push .pot changes to transifex
    tx --debug --traceback push -s
fi

# Pull all upstream translations
tx pull -a

for DOCNAME in ${DocNameList}
do
    git add doc/src/docbkx/${DOCNAME}/locale/*
done

# Don't send a review if the only things which have changed are the creation
# date or comments.
if [ `git diff --cached | egrep -v "(POT-Creation-Date|^[\+\-]#|^\+{3}|^\-{3})" | egrep -c "^[\-\+]"` -gt 0 ]
then
    # Commit and review
    git commit -F- <<EOF
$COMMIT_MSG
EOF
    git review -t transifex/translations

fi
