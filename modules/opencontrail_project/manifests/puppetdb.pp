# == Class: opencontrail_project::puppetdb
#
class opencontrail_project::puppetdb (
  $sysadmins = [],
) {

  # The puppetlabs postgres module does not manage the postgres user
  # and group for us. Create them here to ensure concat can create
  # dirs and files owned by this user and group.
  user { 'postgres':
    ensure  => present,
    gid     => 'postgres',
    system  => true,
    require => Group['postgres'],
  }

  group { 'postgres':
    ensure => present,
    system => true,
  }

  class { 'opencontrail_project::server':
    ssl_listen_address => '0.0.0.0', # works for ipv6 too
    iptables_public_tcp_ports => [8081],
    sysadmins                 => $sysadmins,
  }

  class { 'puppetdb::database::postgresql':
    require         => [User['postgres'],
      Class['opencontrail_project::base'],],
  }

  class { '::puppetdb::server':
    database_host      => 'localhost',
    ssl_listen_address => '0.0.0.0', # works for ipv6 too
    require            => [ User['postgres'],
      Class['puppetdb::database::postgresql'],],
  }

}
