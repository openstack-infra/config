# Copyright 2013 Red Hat, Inc.
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
#
# Class to configure asterisk on a CentOS node.
#
# == Class: openstack_project::pbx
class openstack_project::pbx (
  $sysadmins = [],
) {
  class { 'openstack_project::server':
    sysadmins => $sysadmins,
  }

  class { 'selinux':
    mode => 'enforcing'
  }

  realize (
    User::Virtual::Localuser['rbryant'],
  )

  yumrepo { "asteriskcurrent":
    baseurl => "http://packages.asterisk.org/centos/\$releasever/current/\$basearch/",
    descr => "Asterisk supporting packages produced by Digium",
    enabled => 1,
    gpgcheck => 0
  }

  yumrepo { "asterisk11":
    baseurl => "http://packages.asterisk.org/centos/\$releasever/asterisk-11/\$basearch/",
    descr => "Asterisk packages produced by Digium",
    enabled => 1,
    gpgcheck => 0
  }

  package { 'asterisknow-version' :
    ensure => present,
    require => Yumrepo["asteriskcurrent"]
  }

  package { 'asterisk' :
    ensure => present,
    require => Yumrepo["asterisk11"]
  }
}
