# == Class: openstack_project::template
#
# A template host with no running services
#
class openstack_project::template (
  $iptables_public_tcp_ports = [],
  $iptables_public_udp_ports = [],
  $iptables_rules4           = [],
  $iptables_rules6           = [],
  $pin_puppet                = '2.7',
  $install_users = true,
  $automatic_upgrades = true,
  $certname = $::fqdn
) {
  include ssh
  include snmpd
  if $automatic_upgrades == true {
    include openstack_project::automatic_upgrades
  }

  class { 'iptables':
    public_tcp_ports => $iptables_public_tcp_ports,
    public_udp_ports => $iptables_public_udp_ports,
    rules4           => $iptables_rules4,
    rules6           => $iptables_rules6,
  }

  class { 'ntp': }

  class { 'openstack_project::base':
    install_users => $install_users,
    certname      => $certname,
    pin_puppet    => $pin_puppet,
  }

  package { 'lvm2':
    ensure => present,
  }

  package { 'strace':
    ensure => present,
  }

  package { 'tcpdump':
    ensure => present,
  }

  class { 'unbound': }

  if $::osfamily == 'Debian' {
    # Make sure dig is installed
    package { 'dnsutils':
      ensure => present,
    }

    # Custom rsyslog config to disable /dev/xconsole noise on Debuntu servers
    file { '/etc/rsyslog.d/50-default.conf':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  =>
        'puppet:///modules/openstack_project/rsyslog.d_50-default.conf',
      replace => true,
      notify  => Service['rsyslog'],
    }

    # Ubuntu installs their whoopsie package by default, but it eats through
    # memory and we don't need it on servers
    package { 'whoopsie':
      ensure => absent,
    }
  }

  # Increase syslog message size in order to capture
  # python tracebacks with syslog.
  file { '/etc/rsyslog.d/99-maxsize.conf':
    ensure  => present,
    # Note MaxMessageSize is not a puppet variable.
    content => '$MaxMessageSize 6k',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['rsyslog'],
  }

  service { 'rsyslog':
    ensure     => running,
    enable     => true,
    hasrestart => true,
  }

  if ($::osfamily == 'RedHat') {
    # Make sure dig is installed
    package { 'bind-utils':
      ensure => present,
    }
  }
}
