# == Class: openstack_project::static
#
class openstack_project::static (
  $sysadmins = [],
  $swift_authurl = '',
  $swift_user = '',
  $swift_key = '',
  $swift_tenant_name = '',
  $swift_region_name = '',
  $swift_default_container = '',
) {

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [22, 80, 443],
    sysadmins                 => $sysadmins,
  }

  include openstack_project
  class { 'jenkins::jenkinsuser':
    ssh_key => $openstack_project::jenkins_ssh_key,
  }

  include apache
  include apache::mod::wsgi

  a2mod { 'rewrite':
    ensure => present,
  }
  a2mod { 'proxy':
    ensure => present,
  }
  a2mod { 'proxy_http':
    ensure => present,
  }

  file { '/srv/static':
    ensure => directory,
  }

  ###########################################################
  # Tarballs

  apache::vhost { 'tarballs.openstack.org':
    port     => 80,
    priority => '50',
    docroot  => '/srv/static/tarballs',
    require  => File['/srv/static/tarballs'],
  }

  file { '/srv/static/tarballs':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    require => User['jenkins'],
  }

  ###########################################################
  # CI

  apache::vhost { 'ci.openstack.org':
    port     => 80,
    priority => '50',
    docroot  => '/srv/static/ci',
    require  => File['/srv/static/ci'],
  }

  file { '/srv/static/ci':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    require => User['jenkins'],
  }

  ###########################################################
  # Logs

  apache::vhost { 'logs.openstack.org':
    port     => 80,
    priority => '50',
    docroot  => '/srv/static/logs',
    require  => File['/srv/static/logs'],
    template => 'openstack_project/logs.vhost.erb',
  }

  apache::vhost { 'logs-dev.openstack.org':
    port     => 80,
    priority => '51',
    docroot  => '/srv/static/logs',
    require  => File['/srv/static/logs'],
    template => 'openstack_project/logs-dev.vhost.erb',
  }

  file { '/srv/static/logs':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    require => User['jenkins'],
  }

  file { '/srv/static/logs/robots.txt':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => 'puppet:///modules/openstack_project/disallow_robots.txt',
    require => File['/srv/static/logs'],
  }

  package { 'keyring':
    ensure   => 'latest',
    provider => 'pip',
  }

  vcsrepo { '/opt/os-loganalyze':
    ensure   => latest,
    provider => git,
    revision => 'master',
    source   => 'https://git.openstack.org/openstack-infra/os-loganalyze',
    require  => Package['keyring'],
  }

  exec { 'install_os-loganalyze':
    command     => 'python setup.py install',
    cwd         => '/opt/os-loganalyze',
    path        => '/bin:/usr/bin',
    refreshonly => true,
    subscribe   => Vcsrepo['/opt/os-loganalyze'],
  }

  file { '/etc/os_loganalyze':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Vcsrepo['/opt/os-loganalyze'],
  }

  file { '/etc/os_loganalyze/wsgi.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'www-data',
    mode    => '0440',
    content => template('openstack_project/os-loganalyze-wsgi.conf.erb'),
    require => File['/etc/os_loganalyze'],
  }

  file { '/srv/static/logs/help':
    ensure  => directory,
    recurse => true,
    purge   => true,
    force   => true,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/openstack_project/logs/help',
    require => File['/srv/static/logs'],
  }

  file { '/usr/local/sbin/log_archive_maintenance.sh':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0744',
    source => 'puppet:///modules/openstack_project/log_archive_maintenance.sh',
  }

  cron { 'gziprmlogs':
    user        => 'root',
    minute      => '0',
    hour        => '7',
    weekday     => '6',
    command     => 'bash /usr/local/sbin/log_archive_maintenance.sh',
    environment => 'PATH=/usr/bin:/bin:/usr/sbin:/sbin',
    require     => File['/usr/local/sbin/log_archive_maintenance.sh'],
  }

  ###########################################################
  # Docs-draft

  apache::vhost { 'docs-draft.openstack.org':
    port     => 80,
    priority => '50',
    docroot  => '/srv/static/docs-draft',
    require  => File['/srv/static/docs-draft'],
  }

  file { '/srv/static/docs-draft':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    require => User['jenkins'],
  }

  file { '/srv/static/docs-draft/robots.txt':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => 'puppet:///modules/openstack_project/disallow_robots.txt',
    require => File['/srv/static/docs-draft'],
  }

  ###########################################################
  # Pypi Mirror

  file { '/srv/static/mirror':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
  }

  file { '/srv/static/mirror/web':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    require => File['/srv/static/mirror'],
  }

  file { '/srv/static/mirror/web/openstack':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    require => [User['jenkins'], File['/srv/static/mirror']],
  }

  apache::vhost { 'pypi.openstack.org':
    port     => 80,
    priority => '50',
    docroot  => '/srv/static/mirror/web',
    require  => File['/srv/static/mirror/web'],
  }

  file { '/srv/static/mirror/web/robots.txt':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => 'puppet:///modules/openstack_project/disallow_robots.txt',
    require => File['/srv/static/mirror/web'],
  }

  package { 'bandersnatch':
    ensure   => 'present',
    provider => 'pip',
  }

  file { '/etc/bandersnatch.conf':
    ensure  => present,
    source  => 'puppet:///modules/openstack_project/bandersnatch.conf',
  }

  file { '/var/log/bandersnatch':
    ensure => directory,
  }

  cron { 'bandersnatch':
    minute      => '*/5',
    command     => 'run-bandersnatch >>/var/log/bandersnatch/mirror.log 2>&1',
    environment => 'PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
  }

  include logrotate
  logrotate::file { 'bandersnatch':
    log     => '/var/log/bandersnatch/mirror.log',
    options => [
      'compress',
      'copytruncate',
      'missingok',
      'rotate 7',
      'daily',
      'notifempty',
    ],
  }

  file { '/usr/local/bin/run-bandersnatch':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/openstack_project/run_bandersnatch.py',
  }

  ###########################################################
  # Specs

  apache::vhost { 'specs.openstack.org':
    port     => 80,
    priority => '50',
    docroot  => '/srv/static/specs',
    require  => File['/srv/static/specs'],
  }

  file { '/srv/static/specs':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    require => User['jenkins'],
  }

  file { '/srv/static/specs/robots.txt':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => 'puppet:///modules/openstack_project/disallow_robots.txt',
    require => File['/srv/static/specs'],
  }

}
