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
    sysadmins                 => $sysadmins,
    # SIP signaling is either TCP or UDP port 5060.
    # RTP media (audio/video) uses a range of UDP ports.
    iptables_public_tcp_ports => [5060],
    iptables_public_udp_ports => [5060],
    iptables_rules4           => ['-m udp -p udp --dport 10000:20000 -j ACCEPT'],
    iptables_rules6           => ['-m udp -p udp --dport 10000:20000 -j ACCEPT'],
    sip_username	      => $sip_username,
    sip_password	      => $sip_password,
    sip_hostname	      => $sip_hostname,
    sip_provider	      => $sip_provider,
  }

  class { 'selinux':
    mode => 'enforcing',
  }

  realize (
    User::Virtual::Localuser['rbryant'],
  )

  class { 'asterisk':
    asterisk_conf_source  => 'puppet:///modules/openstack_project/pbx/asterisk/asterisk.conf',
    modules_conf_source   => 'puppet:///modules/openstack_project/pbx/asterisk/modules.conf',
  }

  file {'/etc/asterisk/sip.conf.d/sip.conf':
    ensure  => present,
    owner   => 'asterisk',
    group   => 'asterisk',
    mode    => '0660',
    content => template('openstack_project/pbx/asterisk/sip.conf.erb'),
    require => File['/etc/asterisk/'],
  }

  file {'/etc/asterisk/extensions.conf.d/extensions.conf':
    ensure  => present,
    owner   => 'asterisk',
    group   => 'asterisk',
    mode    => '0660',
    source  => 'puppet:///modules/openstack_project/pbx/asterisk/extensions.conf',
    require => File['/etc/asterisk/'],
  }
}
