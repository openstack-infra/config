# == Class: test_project::pypi_mirror
#
class test_project::pypi_mirror (
  $vhost_name,
  $cron_frequency = '*/5',
) {

  include ::httpd

  if ! defined(File['/srv/static']) {
    file { '/srv/static':
      ensure => directory,
    }
  }

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

  ::httpd::vhost { $vhost_name:
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
    source  => 'puppet:///modules/test_project/disallow_robots.txt',
    require => File['/srv/static/mirror/web'],
  }

  package { 'bandersnatch':
    ensure   => 'latest',
    provider => 'pip',
  }

  file { '/etc/bandersnatch.conf':
    ensure  => present,
    source  => 'puppet:///modules/test_project/bandersnatch.conf',
  }

  file { '/var/log/bandersnatch':
    ensure => directory,
  }

  file { '/var/run/bandersnatch':
    ensure => directory,
  }

  cron { 'bandersnatch':
    minute      => $cron_frequency,
    command     => 'flock -n /var/run/bandersnatch/mirror.lock timeout -k 2m 30m run-bandersnatch >>/var/log/bandersnatch/mirror.log 2>&1',
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
    source  => 'puppet:///modules/test_project/run_bandersnatch.py',
  }
}
