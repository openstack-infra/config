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
  $gerrit_ssh_host_key,
  $imap_username,
  $imap_hostname,
  $imap_password,
  $mqtt_hostname = 'firehose.openstack.org',
  $mqtt_password,
  $mqtt_username = 'infra',
  $statsd_host,
  $ca_file,
  $cert_file,
  $key_file,
) {
  include mosquitto
  class {'mosquitto::server':
    infra_service_username => $mqtt_username,
    infra_service_password => $mqtt_password,
    enable_tls             => true,
    enable_tls_websocket   => true,
    ca_file                => $ca_file,
    cert_file              => $cert_file,
    key_file               => $key_file,
    websocket_tls_port     => 443,
  }

  include germqtt
  class {'germqtt::server':
    gerrit_username     => $gerrit_username,
    gerrit_public_key   => $gerrit_public_key,
    gerrit_private_key  => $gerrit_private_key,
    gerrit_ssh_host_key => $gerrit_ssh_host_key,
    mqtt_username       => $mqtt_username,
    mqtt_password       => $mqtt_password,
  }

  package {'cyrus-imapd':
    ensure => latest,
  }

  package {'sasl2-bin':
    ensure => latest,
  }

  package {'cyrus-admin':
    ensure => latest,
  }

  service {'cyrus-imapd':
    ensure => running,
  }

  include lpmqtt
  class {'lpmqtt::server':
    mqtt_username => $mqtt_username,
    mqtt_password => $mqtt_password,
    imap_hostname => $imap_hostname,
    imap_username => $imap_username,
    imap_password => $imap_password,
    imap_use_ssl  => false,
    imap_delete_old => true,
  }

  include mqtt_statsd
  class {'mqtt_statsd::server':
    mqtt_hostname   => $mqtt_hostname,
    statsd_hostname => $statsd_host,
  }
}
