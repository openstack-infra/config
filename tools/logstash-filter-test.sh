#!/bin/bash -ex

# Copyright 2016 Hewlett-Packard Development Company, L.P.
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

. ./tools/prep-apply.sh

/usr/zuul-env/bin/zuul-cloner --workspace /tmp --cache-dir /opt/git \
    git://git.openstack.org \
    openstack-infra/logstash-filters
sha=$(git --git-dir=/tmp/openstack-infra/logstash-filters/.git rev-parse HEAD)

cat > node.pp <<EOF
  \$elasticsearch_nodes = [ 'localhost' ]
  class { 'openstack_project::logstash_worker':
    filter_source => 'file:///tmp/openstack-infra/logstash-filters/.git',
    filter_rev    => '$sha',
  }
EOF

sudo apt-get update  # Update apt cache before running puppet
sudo puppet apply --modulepath=${MODULE_PATH} --color=false --debug node.pp

/usr/bin/java -jar /opt/logstash/logstash.jar agent --configtest -f /etc/logstash/conf.d
