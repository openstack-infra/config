# == Class: openstack_project::zuul_merger
#
class openstack_project::zuul_merger(
  $vhost_name = $::fqdn,
  $gearman_server = '127.0.0.1',
  $gerrit_server = '',
  $gerrit_user = '',
  $gerrit_ssh_host_key = '',
  $gerrit_ssh_host_identity = [],
  $zuul_ssh_private_key = '',
  $zuul_url = "http://${::fqdn}/p",
  $sysadmins = [],
  $git_email = 'jenkins@openstack.org',
  $git_name = 'OpenStack Jenkins',
) {

  $gerrit_ssh_ident = inline_template("<%= (@gerrit_ssh_host_identity).join(',') %> <%= @gerrit_ssh_host_key %>")

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80],
    sysadmins                 => $sysadmins,
  }

  class { '::zuul':
    vhost_name           => $vhost_name,
    gearman_server       => $gearman_server,
    gerrit_server        => $gerrit_server,
    gerrit_user          => $gerrit_user,
    zuul_ssh_private_key => $zuul_ssh_private_key,
    zuul_url             => $zuul_url,
    git_email            => $git_email,
    git_name             => $git_name,
  }

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
      content => $gerrit_ssh_ident,
      replace => true,
      require => File['/home/zuul/.ssh'],
    }
  }

  file { '/etc/zuul/merger-logging.conf':
    ensure => present,
    source => 'puppet:///modules/openstack_project/zuul/merger-logging.conf',
  }
}
