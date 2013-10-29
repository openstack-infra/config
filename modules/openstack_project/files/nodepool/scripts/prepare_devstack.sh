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

mkdir -p ~/cache/files
mkdir -p ~/cache/pip

if cat /etc/*release | grep -e "Fedora\|Red Hat" &> /dev/null; then

    sudo yum -y install python-devel make automake gcc gcc-c++ kernel-devel

else
    # Default ubuntu
    sudo DEBIAN_FRONTEND=noninteractive apt-get \
      --option "Dpkg::Options::=--force-confold" \
      --assume-yes install build-essential python-dev \
      linux-headers-virtual linux-headers-`uname -r`
fi

rm -rf ~/workspace-cache
mkdir -p ~/workspace-cache

cd ~/workspace-cache
git clone https://review.openstack.org/p/openstack-dev/devstack
git clone https://review.openstack.org/p/openstack-dev/grenade
git clone https://review.openstack.org/p/openstack-dev/pbr
git clone https://review.openstack.org/p/openstack-infra/devstack-gate
git clone https://review.openstack.org/p/openstack-infra/jeepyb
git clone https://review.openstack.org/p/openstack-infra/pypi-mirror
git clone https://review.openstack.org/p/openstack/ceilometer
git clone https://review.openstack.org/p/openstack/cinder
git clone https://review.openstack.org/p/openstack/glance
git clone https://review.openstack.org/p/openstack/heat
git clone https://review.openstack.org/p/openstack/horizon
git clone https://review.openstack.org/p/openstack/keystone
git clone https://review.openstack.org/p/openstack/neutron
git clone https://review.openstack.org/p/openstack/nova
git clone https://review.openstack.org/p/openstack/oslo.config
git clone https://review.openstack.org/p/openstack/oslo.messaging
git clone https://review.openstack.org/p/openstack/python-ceilometerclient
git clone https://review.openstack.org/p/openstack/python-cinderclient
git clone https://review.openstack.org/p/openstack/python-glanceclient
git clone https://review.openstack.org/p/openstack/python-heatclient
git clone https://review.openstack.org/p/openstack/python-keystoneclient
git clone https://review.openstack.org/p/openstack/python-neutronclient
git clone https://review.openstack.org/p/openstack/python-novaclient
git clone https://review.openstack.org/p/openstack/python-openstackclient
git clone https://review.openstack.org/p/openstack/python-swiftclient
git clone https://review.openstack.org/p/openstack/requirements
git clone https://review.openstack.org/p/openstack/swift
git clone https://review.openstack.org/p/openstack/tempest
# and stackforge libraries we might want to test with
git clone https://review.openstack.org/p/stackforge/pecan
git clone https://review.openstack.org/p/stackforge/wsme

# Fedora don't have /etc/lsb-release
if cat /etc/*release | grep -e "Fedora\|Red Hat" &> /dev/null; then
    DISTRIB_CODENAME="Fedora"
else
    . /etc/lsb-release
fi

cd /opt/nodepool-scripts/
python ./devstack-cache.py $DISTRIB_CODENAME

sync
sleep 5
