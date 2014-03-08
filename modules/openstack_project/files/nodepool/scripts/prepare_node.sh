#!/bin/bash -xe

# Copyright (C) 2011-2013 OpenStack Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
#
# See the License for the specific language governing permissions and
# limitations under the License.

HOSTNAME=$1
SUDO=$2
BARE=$3
PYTHON3=${4:-false}
PYPY=${5:-false}
ALL_MYSQL_PRIVS=${6:-false}

CGIT_SITE=https://git.openstack.org/cgit
GIT_ORIGIN=git://git.openstack.org
PROJECTS_YAML_URL=$CGIT_SITE/openstack-infra/config/plain/modules/openstack_project/files/review.projects.yaml

sudo hostname $HOSTNAME
wget $CGIT_SITE/openstack-infra/config/plain/install_puppet.sh
sudo bash -xe install_puppet.sh
sudo git clone --depth=1 $GIT_ORIGIN/openstack-infra/config.git \
    /root/config
sudo /bin/bash /root/config/install_modules.sh
if [ -z "$NODEPOOL_SSH_KEY" ] ; then
    sudo puppet apply --modulepath=/root/config/modules:/etc/puppet/modules \
	-e "class {'openstack_project::single_use_slave': sudo => $SUDO, bare => $BARE, python3 => $PYTHON3, include_pypy => $PYPY, all_mysql_privs => $ALL_MYSQL_PRIVS, }"
else
    sudo puppet apply --modulepath=/root/config/modules:/etc/puppet/modules \
	-e "class {'openstack_project::single_use_slave': install_users => false, sudo => $SUDO, bare => $BARE, python3 => $PYTHON3, include_pypy => $PYPY, all_mysql_privs => $ALL_MYSQL_PRIVS, ssh_key => '$NODEPOOL_SSH_KEY', }"
fi

sudo mkdir -p /opt/git
sudo -i python /opt/nodepool-scripts/cache_git_repos.py $PROJECTS_YAML_URL

# We don't always get ext4 from our clouds, mount ext3 as ext4 on the next
# boot (eg when this image is used for testing).
sudo sed -i 's/ext3/ext4/g' /etc/fstab

sync
sleep 5
