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

# == Class: mysql_proxy::server
#
class mysql_proxy::server (
  $db_host,
  $db_port='3306',
) {

  file { '/etc/mysql-proxy/mysql-proxy.conf':
    ensure  => absent,
  }

  service{ 'mysql-proxy':
    ensure  => absent,
  }

  exec{ 'simpleproxy-mysql':
    command => 'simpleproxy -L3306 -R ${db_host}:${db_port} -d',
    path    => '/usr/local/bin:/usr/bin:/bin/',
  }
}
