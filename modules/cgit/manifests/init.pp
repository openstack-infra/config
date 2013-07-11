# Copyright 2013 Hewlett-Packard Development Company, L.P.
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
# Class: cgit
#
class cgit {

  include apache

  package { [
      'cgit',
      'git-daemon',
    ]:
    ensure => present,
  }

  service { 'httpd':
    ensure     => running,
    require    => Package['httpd'],
  }

  file { '/var/lib/git':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  exec { 'restorecon -R -v /var/lib/git':
    path      => '/sbin',
    subscribe => Folder['/var/lib/git']
  }

  selboolean { 'httpd_enable_cgi':
    persistent => true,
    value      => on
  }

  file { '/etc/httpd/conf.d/cgit.conf':
    ensure  => present,
    source  => 'puppet:///modules/cgit/cgit.conf',
    mode    => '0644'
  }
}
