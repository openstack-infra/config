# == Class: openstack_project::puppetmaster
#
class openstack_project::puppetmaster (
  $root_rsa_key,
  $sysadmins = []
) {
  include ansible
  include logrotate
  include openstack_project::params

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [4505, 4506, 8140],
    sysadmins                 => $sysadmins,
  }

  cron { 'updatepuppetmaster':
    user        => 'root',
    minute      => '*/15',
    command     => 'bash /opt/config/production/run_all.sh',
    environment => 'PATH=/var/lib/gems/1.8/bin:/usr/bin:/bin:/usr/sbin:/sbin',
  }
  logrotate::file { 'updatepuppetmaster':
    ensure  => present,
    log     => '/var/log/puppet_run_all.log',
    options => ['compress',
      'copytruncate',
      'delaycompress',
      'missingok',
      'rotate 7',
      'daily',
      'notifempty',
    ],
    require => Cron['updatepuppetmaster'],
  }

  cron { 'deleteoldreports':
    user        => 'root',
    hour        => '3',
    minute      => '0',
    command     => 'sleep $((RANDOM\%600)) && find /var/lib/puppet/reports -name \'*.yaml\' -mtime +7 -execdir rm {} \;',
    environment => 'PATH=/var/lib/gems/1.8/bin:/usr/bin:/bin:/usr/sbin:/sbin',
  }

  file { '/etc/puppet/hiera.yaml':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0555',
    source  => 'puppet:///modules/openstack_project/puppetmaster/hiera.yaml',
    replace => true,
    require => Class['openstack_project::server'],
  }

  file { '/var/lib/puppet/reports':
    ensure => directory,
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '0750',
    }

  if ! defined(File['/root/.ssh']) {
    file { '/root/.ssh':
      ensure => directory,
      mode   => '0700',
    }
  }

  file { '/root/.ssh/id_rsa':
    ensure  => present,
    mode    => '0400',
    content => $root_rsa_key,
  }

# Cloud credentials are stored in this directory for launch-node.py.
  file { '/root/ci-launch':
    ensure => directory,
    owner  => 'root',
    group  => 'admin',
    mode   => '0750',
    }

# For launch/launch-node.py.
  package { ['python-cinderclient', 'python-novaclient']:
    ensure   => latest,
    provider => pip,
  }
  package { 'python-paramiko':
    ensure => present,
  }

# Enable puppetdb

  class { 'puppetdb::master::config':
    puppetdb_server              => 'puppetdb.openstack.org',
    puppet_service_name          => 'apache2',
    puppetdb_soft_write_failure  => true,
  }

  file { '/etc/ansible/hosts':
    ensure  => present,
    source  => 'puppet:///modules/openstack_project/ansible/hosts',
    require => Class[ansible],
  }

# Playbooks
#
  file { '/etc/ansible/clean_workspaces.yaml':
    ensure  => present,
    source  => 'puppet:///modules/openstack_project/ansible/clean_workspaces.yaml',
    require => Class[ansible],
  }

  file { '/etc/ansible/run_mirror.yaml':
    ensure  => present,
    source  => 'puppet:///modules/openstack_project/ansible/run_mirror.yaml',
    require => Class[ansible],
  }

  file { '/etc/ansible/remove_from_mirror.yaml':
    ensure  => present,
    source  => 'puppet:///modules/openstack_project/ansible/remove_from_mirror.yaml',
    require => Class[ansible],
  }

  file { '/etc/ansible/remote_puppet.yaml':
    ensure  => present,
    source  => 'puppet:///modules/openstack_project/ansible/remote_puppet.yaml',
    require => Class[ansible],
  }

}
