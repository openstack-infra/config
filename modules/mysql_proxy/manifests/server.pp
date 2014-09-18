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
  $db_host_and_port,
  $lua_script = '/usr/share/mysql-proxy/rw-splitting.lua',
  $admin_username = 'admin',
  $admin_pass,
) {

  file { '/etc/mysql-proxy/mysql-proxy.conf':
    ensure   => file,
    owner    => 'root',
    group    => 'root',
    mode     => '0600',
    content  => template("mysql_proxy/mysql-proxy.conf.erb"),
    require  => File['/etc/mysql-proxy']
  }

  service{ 'mysql-proxy':
    ensure => running,
    subscribe => [
      Package['mysql-proxy'],
      File['/etc/mysql-proxy/mysql-proxy.conf'],
    ],
  }
}
