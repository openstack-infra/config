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
# openstack-health api worker glue class.
#
class openstack_project::openstack_health (
  $sysadmins = [],
  $subunit2sql_db_host,
  $subunit2sql_db_user = 'query',
  $subunit2sql_db_name = 'subunit2sql',
  $subunit2sql_db_pass = 'query',
  $hostname,
  $sysadmins,
) {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [22],
    sysadmins                 => $sysadmins,
  }

  include openstack-health
  openstack-health::api { 'api_server':
    db_uri      => "mysq;+pymysql://${subunit2sql_db_user}:${subunit2sql_db_pass}@${subunit2sql_db_host}/${subunit2sql_db_name}",
    $vhost_name => $hostname,
    $vhost_port => 80,
  }
}
