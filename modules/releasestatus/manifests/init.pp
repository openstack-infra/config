# Copyright 2013 Thierry Carrez
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
# Class: releasestatus
#
class releasestatus {
  if ! defined(Package['python-launchpadlib']) {
    package { 'python-launchpadlib':
      ensure => present,
    }
  }
  package { 'python-jinja2':
    ensure => present,
  }
  package { 'python-yaml':
    ensure => present,
  }

  file {'/var/lib/releasestatus':
    ensure  => directory,
    owner   => 'releasestatus',
    group   => 'releasestatus',
    mode    => '0755',
    require => User['releasestatus'],
  }

  group { 'releasestatus':
    ensure => present,
  }

  user { 'releasestatus':
    ensure     => present,
    home       => '/var/lib/releasestatus',
    shell      => '/bin/bash',
    gid        => 'releasestatus',
    managehome => true,
    require    => Group['releasestatus'],
  }

}

# vim:sw=2:ts=2:expandtab:textwidth=79
