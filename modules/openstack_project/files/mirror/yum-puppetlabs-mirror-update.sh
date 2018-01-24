#!/bin/bash -xe
# Copyright 2016 Red Hat, Inc.
#
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

MIRROR_VOLUME=$1

BASE="/afs/.openstack.org/mirror/yum-puppetlabs"
MIRROR="rsync://rsync.puppet.com/packages"
K5START="k5start -t -f /etc/yum-puppetlabs.keytab service/yum-puppetlabs-mirror -- timeout -k 2m 30m"

if ! [ -f $BASE ]; then
    $K5START mkdir -p $BASE
fi

date --iso-8601=ns
echo "Running rsync..."
$K5START rsync -rlptDvz \
    --delete \
    --delete-excluded \
    # We don't need this arch in OpenStack Infra.
    --exclude="cisco-wrlinux"
    $MIRROR/packages/yum $BASE

# TODO(pabelanger): Validate rsync process

date --iso-8601=ns | $K5START tee $BASE/timestamp.txt
echo "rsync completed successfully, running vos release."
k5start -t -f /etc/afsadmin.keytab service/afsadmin -- vos release -v $MIRROR_VOLUME

date --iso-8601=ns
echo "Done."
