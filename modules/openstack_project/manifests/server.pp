# == Class: openstack_project::server
#
# A server that we expect to run for some time
class openstack_project::server (
  $iptables_public_tcp_ports = [],
  $iptables_public_udp_ports = [],
  $iptables_rules4           = [],
  $iptables_rules6           = [],
  $sysadmins                 = [],
  $certname                  = $::fqdn,
  $pin_puppet                = '3.',
  $ca_server                 = undef,
  $enable_unbound            = true,
  $afs                       = false,
  $puppetmaster_server       = 'puppetmaster.openstack.org',
  $manage_exim               = true,
) {
  class { 'openstack_project::template':
    iptables_public_tcp_ports => $iptables_public_tcp_ports,
    iptables_public_udp_ports => $iptables_public_udp_ports,
    iptables_rules4           => $iptables_rules4,
    iptables_rules6           => $iptables_rules6,
    certname                  => $certname,
    pin_puppet                => $pin_puppet,
    ca_server                 => $ca_server,
    puppetmaster_server       => $puppetmaster_server,
    enable_unbound            => $enable_unbound,
    afs                       => $afs,
    manage_exim               => $manage_exim,
    sysadmins                 => $sysadmins,
    purge_apt_sources         => true,
  }
}
