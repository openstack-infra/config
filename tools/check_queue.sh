#!/bin/bash
#
# Script to queue changes in the check queue, a list of changes should be
# in a file you export to an env var for prior to running the script:
#
#   export CHANGES=changes.txt
#
# This is a comma-delimited file that needs to have the project, change number
# and patchset number, for instance:
#
# openstack/nova,123456,5
# openstack/neutron,123457,2

while IFS=, read -r -a input; do
    sudo zuul enqueue --trigger gerrit --pipeline check --project ${input[0]} --change ${input[1]},${input[2]}
done < $CHANGES
