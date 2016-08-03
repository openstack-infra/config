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
#
# firehose glue class.
#
class openstack_project::firehose (
  $gerrit_username = 'germqtt',
  $gerrit_public_key,
  $gerrit_private_key,
  $ssh_known_hosts,
  $mqtt_hostname = 'firehose01.openstack.org',
  $mqtt_password,
  $mqtt_username = 'infra',
) {
  include mosquitto
  class {'mosquitto::server':
    infra_service_username => $mqtt_username,
    infra_service_password => $mqtt_password,
  }

  include germqtt
  class {'germqtt::server':
    gerrit_username     => $gerrit_username,
    gerrit_public_key   => $gerrit_public_key,
    gerrit_private_key  => $gerrit_private_key,
    ssh_known_hosts     => $ssh_known_hosts,
    mqtt_username       => $mqtt_username,
    mqtt_password       => $mqtt_password,
  }
}
