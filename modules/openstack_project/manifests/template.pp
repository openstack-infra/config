# == Class: openstack_project::template
#
# A template host with no running services
#
class openstack_project::template (
  $iptables_public_tcp_ports = [],
  $iptables_public_udp_ports = [],
  $iptables_rules4           = [],
  $iptables_rules6           = [],
  $snmp_v4hosts              = [],
  $snmp_v6hosts              = [],
  $pin_puppet                = '3.',
  $install_users             = true,
  $install_resolv_conf       = true,
  $automatic_upgrades        = true,
  $certname                  = $::fqdn,
  $ca_server                 = undef,
  $afs                       = false,
  $afs_cache_size            = 500000,
  $puppetmaster_server       = 'puppetmaster.openstack.org',
  $manage_exim               = false,
  $sysadmins                 = [],
  $pypi_index_url            = 'https://pypi.python.org/simple',
  $permit_root_login         = 'no',
) {

  ###########################################################
  # Classes for all hosts
  include sudoers

  include openstack_project::params
  include openstack_project::users

  if ( $afs ) {
    $all_udp = concat(
      $iptables_public_udp_ports, [7001])

    class { 'openafs::client':
      cell         => 'openstack.org',
      realm        => 'OPENSTACK.ORG',
      admin_server => 'kdc.openstack.org',
      cache_size   => $afs_cache_size,
      kdcs         => [
        'kdc01.openstack.org',
        'kdc02.openstack.org',
      ],
    }
  } else {
    $all_udp = $iptables_public_udp_ports
  }

  class { 'iptables':
    public_tcp_ports => $iptables_public_tcp_ports,
    public_udp_ports => $all_udp,
    rules4           => $iptables_rules4,
    rules6           => $iptables_rules6,
    snmp_v4hosts     => $snmp_v4hosts,
    snmp_v6hosts     => $snmp_v6hosts,
  }

  class { 'timezone':
    timezone => 'Etc/UTC',
  }

  ###########################################################
  # Process if ( $high_level_directive ) blocks

  if $manage_exim {
    class { 'exim':
      sysadmins => $sysadmins,
    }
  }

  if $automatic_upgrades == true {
    class { 'openstack_project::automatic_upgrades':
      origins => ["Puppetlabs:${lsbdistcodename}"],
    }
  }

  class {'openstack_project::users_install':
    install_users => $install_users
  }

  package { 'rsyslog':
    ensure => present,
  }

  if ($::in_chroot) {
    notify { 'rsyslog in chroot':
      message => 'rsyslog not refreshed, running in chroot',
    }
    $rsyslog_notify = []
  } else {
    service { 'rsyslog':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      require    => Package['rsyslog'],
    }
    $rsyslog_notify = [ Service['rsyslog'] ]
  }

  ###########################################################
  # System tweaks

  # Increase syslog message size in order to capture
  # python tracebacks with syslog.
  file { '/etc/rsyslog.d/99-maxsize.conf':
    ensure  => present,
    # Note MaxMessageSize is not a puppet variable.
    content => '$MaxMessageSize 6k',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => $rsyslog_notify,
    require => Package['rsyslog'],
  }

  # We don't like byobu
  file { '/etc/profile.d/Z98-byobu.sh':
    ensure => absent,
  }

  if $::osfamily == 'Debian' {

    # Custom rsyslog config to disable /dev/xconsole noise on Debuntu servers
    file { '/etc/rsyslog.d/50-default.conf':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  =>
        'puppet:///modules/openstack_project/rsyslog.d_50-default.conf',
      replace => true,
      notify  => $rsyslog_notify,
      require => Package['rsyslog'],
    }

    # Ubuntu installs their whoopsie package by default, but it eats through
    # memory and we don't need it on servers
    package { 'whoopsie':
      ensure => absent,
    }

    package { 'popularity-contest':
      ensure => absent,
    }
  }

  ###########################################################
  # Manage  python/pip

  $desired_virtualenv = '13.1.0'
  class { '::pip':
    index_url       => $pypi_index_url,
    optional_settings => {
      'extra-index-url' => '',
    },
    manage_pip_conf => true,
  }

  if (( versioncmp($::virtualenv_version, $desired_virtualenv) < 0 )) {
    $virtualenv_ensure = $desired_virtualenv
  } else {
    $virtualenv_ensure = present
  }
  package { 'virtualenv':
    ensure   => $virtualenv_ensure,
    provider => openstack_pip,
    require  => Class['pip'],
  }

  ###########################################################
  # Manage Puppet
  # possible TODO: break this into openstack_project::puppet

  case $pin_puppet {
    '2.7.': {
      $pin_facter = '1.'
      $pin_puppetdb = '1.'
    }
    /^3\./: {
      $pin_facter = '2.'
      $pin_puppetdb = '2.'
    }
    default: {
      fail("Puppet version not supported")
    }
  }

  if ($::operatingsystem == 'Fedora') {

    package { 'hiera':
      ensure   => latest,
      provider => 'gem',
    }

    exec { 'symlink hiera modules' :
      command     => 'ln -s /usr/local/share/gems/gems/hiera-puppet-* /etc/puppet/modules/',
      path        => '/bin:/usr/bin',
      subscribe   => Package['hiera'],
      refreshonly => true,
    }

  }

  # Which Puppet do I take?
  # Take $puppet_version and pin to that version
  if ($::osfamily == 'Debian') {
    # NOTE(pabelanger): Puppetlabs only support Ubuntu Trusty and below,
    # anything greater will use the OS version of puppet.
    if ($::operatingsystemrelease < '15.04') {
      include ::apt
      apt::source { 'puppetlabs':
        location => 'http://apt.puppetlabs.com',
        repos    => 'main',
        key      => {
          'id'     =>'47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30',
          'server' => 'pgp.mit.edu',
        },
      }
    }

    file { '/etc/security/limits.d/60-nofile-limit.conf':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => 'puppet:///modules/openstack_project/debian_limits.conf',
      replace => true,
    }

    file { '/etc/apt/apt.conf.d/80retry':
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      source  => 'puppet:///modules/openstack_project/80retry',
      replace => true,
    }

    file { '/etc/apt/apt.conf.d/90no-translations':
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      source  => 'puppet:///modules/openstack_project/90no-translations',
      replace => true,
    }

    file { '/etc/apt/preferences.d/00-puppet.pref':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      content => template('openstack_project/00-puppet.pref.erb'),
      replace => true,
    }

    file { '/etc/default/puppet':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      source  => 'puppet:///modules/openstack_project/puppet.default',
      replace => true,
    }

  }

  if ($::operatingsystem == 'CentOS') {
    if ($::operatingsystemmajrelease == '6') {
      $puppet_repo_source_path =
        'puppet:///modules/openstack_project/centos6-puppetlabs.repo'
      $custom_cgit = present
    } elsif ($::operatingsystemmajrelease == '7') {
      $puppet_repo_source_path =
        'puppet:///modules/openstack_project/centos7-puppetlabs.repo'
      $custom_cgit = absent
    }
    file { '/etc/yum.repos.d/puppetlabs.repo':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      source  => $puppet_repo_source_path,
      replace => true,
    }

    # This git package includes a small work-around for slow https
    # cloning performance, as discussed in redhat bz#1237395.  Should
    # be fixed in 6.8
    file { '/etc/yum.repos.d/git-1237395.repo':
      ensure  => $custom_cgit,
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      source  => 'puppet:///modules/openstack_project/git-1237395.repo',
      replace => true,
    }

  }

  $puppet_version = $pin_puppet

  service { 'puppet':
    ensure => stopped,
    enable => false,
  }

  ###########################################################

}
