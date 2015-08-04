#!/bin/bash

# Copyright 2014 Hewlett-Packard Development Company, L.P.
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

set -e

export BIFROST_INVENTORY_SOURCE=/opt/stack/baremetal.json

pushd /opt/stack/bifrost/playbooks

# Install
/usr/bin/ansible-playbook -vvvv -i inventory/localhost install.yaml

# Enroll-dynamic
export BIFROST_INVENTORY_SOURCE=/opt/stack/baremetal.json
/usr/bin/ansible-playbook -vvvv -i inventory/bifrost_inventory.py enroll-dynamic.yaml

# Deploy-dynamic
/usr/bin/ansible-playbook -vvvv -i inventory/bifrost_inventory.py deploy-dynamic.yaml
