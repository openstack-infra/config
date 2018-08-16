# Class to configure cacti on a node.
class openstack_project::cacti (
  $cacti_hosts = [],
  $vhost_name = '',
) {

  if $::osfamily != 'Debian' {
    fail("${::osfamily} is not supported.")
  }

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80, 443],
  }

  class { '::apache':
    default_vhost => false,
    mpm_module => 'prefork',
  }
  class { '::apache::mod::rewrite': }
  class { '::apache::mod::php': }

  package { 'cacti':
    ensure => present,
  }

  ::apache::listen { '80': }
  ::apache::listen { '443': }

  ::apache::vhost::custom { $::fqdn:
    ensure  => present,
    content => template('openstack_project/cacti.vhost.erb'),
  }

  file { '/usr/local/share/cacti/resource/snmp_queries':
    ensure  => directory,
    owner   => 'root',
    require => Package['cacti'],
  }

  file { '/usr/local/share/cacti/resource/snmp_queries/net-snmp_devio.xml':
    ensure  => present,
    source  => 'puppet:///modules/openstack_project/cacti/net-snmp_devio.xml',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => File['/usr/local/share/cacti/resource/snmp_queries'],
  }

  file { '/var/lib/cacti':
    ensure  => directory,
    require => Package['cacti'],
  }

  file { '/var/lib/cacti/linux_host.xml':
    ensure  => present,
    source  => 'puppet:///modules/openstack_project/cacti/linux_host.xml',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => [
      File['/usr/local/share/cacti/resource/snmp_queries/net-snmp_devio.xml'],
      File['/var/lib/cacti'],
    ],
  }

  file { '/usr/local/bin/create_graphs.sh':
    ensure => present,
    source => 'puppet:///modules/openstack_project/cacti/create_graphs.sh',
    mode   => '0744',
    owner  => 'root',
    group  => 'root',
  }

  exec { 'cacti_import_xml':
    command => '/usr/bin/php -q /usr/share/cacti/cli/import_template.php --filename=/var/lib/cacti/linux_host.xml --with-template-rras',
    cwd     => '/usr/share/cacti/cli',
    require => File['/var/lib/cacti/linux_host.xml'],
  }

  file { '/var/lib/cacti/devices':
    ensure  => present,
    content => join($cacti_hosts, " "),
    mode    => '0744',
    owner   => 'root',
    group   => 'root',
    require => File['/var/lib/cacti'],
  }

  cron { 'add cacti hosts':
    ensure  => present,
    user    => root,
    command => 'for host in $(cat /var/lib/cacti/devices); do /usr/local/bin/create_graphs.sh $host >> /var/log/cacti_update.log 2>&1; done',
    minute  => '0',
  }

  include logrotate
  logrotate::file { 'cacti_update.log':
    log     => '/var/log/cacti_update.log',
    options => [
      'compress',
      'missingok',
      'rotate 7',
      'daily',
      'notifempty',
      'copytruncate',
    ],
    require => Cron['add cacti hosts'],
  }
}
