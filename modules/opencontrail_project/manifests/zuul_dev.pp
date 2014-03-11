# == Class: opencontrail_project::zuul_dev
#
class opencontrail_project::zuul_dev(
  $vhost_name = $::fqdn,
  $gearman_server = '127.0.0.1',
  $gerrit_server = '',
  $gerrit_user = '',
  $gerrit_ssh_host_key = '',
  $zuul_ssh_private_key = '',
  $url_pattern = '',
  $zuul_url = '',
  $sysadmins = [],
  $statsd_host = '',
  $gearman_workers = [],
) {

  realize (
    User::Virtual::Localuser['zaro'],
  )

  # Turn a list of hostnames into a list of iptables rules
  $iptables_rules = regsubst ($gearman_workers, '^(.*)$', '-m state --state NEW -m tcp -p tcp --dport 4730 -s \1 -j ACCEPT')

  class { 'opencontrail_project::server':
    iptables_public_tcp_ports => [80],
    iptables_rules6           => $iptables_rules,
    iptables_rules4           => $iptables_rules,
    sysadmins                 => $sysadmins,
  }

  class { '::zuul':
    vhost_name           => $vhost_name,
    gearman_server       => $gearman_server,
    gerrit_server        => $gerrit_server,
    gerrit_user          => $gerrit_user,
    zuul_ssh_private_key => $zuul_ssh_private_key,
    url_pattern          => $url_pattern,
    zuul_url             => $zuul_url,
    job_name_in_report   => true,
    status_url           => 'http://zuul-dev.opencontrail.org/',
    statsd_host          => $statsd_host,
    git_email            => 'jenkins@opencontrail.org',
    git_name             => 'OpenStack Jenkins',
  }

  class { '::zuul::server': }
  class { '::zuul::merger': }

  if $gerrit_ssh_host_key != '' {
    file { '/home/zuul/.ssh':
      ensure  => directory,
      owner   => 'zuul',
      group   => 'zuul',
      mode    => '0700',
      require => Class['::zuul'],
    }
    file { '/home/zuul/.ssh/known_hosts':
      ensure  => present,
      owner   => 'zuul',
      group   => 'zuul',
      mode    => '0600',
      content => "review.opencontrail.org,198.101.231.251,2001:4800:780d:509:3bc3:d7f6:ff04:39f0 ${gerrit_ssh_host_key}",
      replace => true,
      require => File['/home/zuul/.ssh'],
    }
  }

  file { '/etc/zuul/layout.yaml':
    ensure => present,
    source => 'puppet:///modules/opencontrail_project/zuul/layout-dev.yaml',
    notify => Exec['zuul-reload'],
  }

  file { '/etc/zuul/opencontrail_functions.py':
    ensure => present,
    source => 'puppet:///modules/opencontrail_project/zuul/opencontrail_functions.py',
    notify => Exec['zuul-reload'],
  }

  file { '/etc/zuul/logging.conf':
    ensure => present,
    source => 'puppet:///modules/opencontrail_project/zuul/logging.conf',
    notify => Exec['zuul-reload'],
  }

  file { '/etc/zuul/gearman-logging.conf':
    ensure => present,
    source => 'puppet:///modules/opencontrail_project/zuul/gearman-logging.conf',
    notify => Exec['zuul-reload'],
  }

  file { '/etc/zuul/merger-logging.conf':
    ensure => present,
    source => 'puppet:///modules/opencontrail_project/zuul/merger-logging.conf',
  }

  class { '::recheckwatch':
    gerrit_server                => $gerrit_server,
    gerrit_user                  => $gerrit_user,
    recheckwatch_ssh_private_key => $zuul_ssh_private_key,
  }

  file { '/var/lib/recheckwatch/scoreboard.html':
    ensure  => present,
    source  => 'puppet:///modules/opencontrail_project/zuul/scoreboard.html',
    require => File['/var/lib/recheckwatch'],
  }
}
