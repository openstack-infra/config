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


cd /opt/system-config/production
git fetch -a && git reset -q --hard @{u}
./install_modules.sh

# One must touch manifests/site.pp to trick puppet into re-loading modules
# some times
touch manifests/site.pp

# Run this as an external script so that the above pull will get new changes
ansible-playbook /etc/ansible/remote_puppet.yaml >> /var/log/puppet_run_all.log 2>&1
# Run AFS changes separately so we can make sure to only do one at a time
# (turns out quorum is nice to have)
ansible-playbook -f 1 /etc/ansible/remote_puppet_afs.yaml >> /var/log/puppet_run_all.log 2>&1
