# == Class: openstack_project::base
#
class openstack_project::base(
  $certname = $::fqdn,
  $install_users = true
) {
  if ($::osfamily == 'Debian') {
    include apt
  }
  include openstack_project::params
  include openstack_project::users
  include sudoers

  file { '/etc/profile.d/Z98-byobu.sh':
    ensure => absent,
  }

  package { 'popularity-contest':
    ensure => absent,
  }

  package { 'git':
    ensure => present,
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

  package { $::openstack_project::params::packages:
    ensure => present
  }

  include pip
  $desired_virtualenv = '1.10.1'

  if (( versioncmp($::virtualenv_version, $desired_virtualenv) < 0 )) {
    $virtualenv_ensure = $desired_virtualenv
  } else {
    $virtualenv_ensure = present
  }
  package { 'virtualenv':
    ensure   => $virtualenv_ensure,
    provider => pip,
    require  => Class['pip'],
  }

  if ($install_users) {
    package { $::openstack_project::params::user_packages:
      ensure => present
    }

    realize (
      User::Virtual::Localuser['mordred'],
      User::Virtual::Localuser['corvus'],
      User::Virtual::Localuser['clarkb'],
      User::Virtual::Localuser['fungi'],
    )
  }

  if ! defined(File['/root/.ssh']) {
    file { '/root/.ssh':
      ensure => directory,
      mode   => '0700',
    }
  }

  ssh_authorized_key { 'puppet-remote-2014-04-17':
    ensure  => present,
    user    => 'root',
    type    => 'ssh-rsa',
    key     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDSLlN41ftgxkNeUi/kATYPwMPjJdMaSbgokSb9PSkRPZE7GeNai60BCfhu+ky8h5eMe70Bpwb7mQ7GAtHGXPNU1SRBPhMuVN9EYrQbt5KSiwuiTXtQHsWyYrSKtB+XGbl2PhpMQ/TPVtFoL5usxu/MYaakVkCEbt5IbPYNg88/NKPixicJuhi0qsd+l1X1zoc1+Fn87PlwMoIgfLIktwaL8hw9mzqr+pPcDIjCFQQWnjqJVEObOcMstBT20XwKj/ymiH+6p123nnlIHilACJzXhmIZIZO+EGkNF7KyXpcBSfv9efPI+VCE2TOv/scJFdEHtDFkl2kdUBYPC0wQ92rp',
    options => [
      "command=\"${::openstack_project::params::allowed_ssh_command}\"",
      'from="ci-puppetmaster.openstack.org"',
    ],
    require => File['/root/.ssh'],
  }
  ssh_authorized_key { '/root/.ssh/authorized_keys':
    ensure  => absent,
    user    => 'root',
  }

  # Use upstream puppet and pin to version 2.7.*
  if ($::osfamily == 'Debian') {
    apt::source { 'puppetlabs':
      location   => 'http://apt.puppetlabs.com',
      repos      => 'main',
      key        => '4BD6EC30',
      key_server => 'pgp.mit.edu',
    }

    case $::lsbdistcodename {
      'trusty': {
        file { '/etc/apt/preferences.d/00-puppet.pref':
          ensure => absent,
        }
      }

      default: {
        file { '/etc/apt/preferences.d/00-puppet.pref':
          ensure  => present,
          owner   => 'root',
          group   => 'root',
          mode    => '0444',
          source  => 'puppet:///modules/openstack_project/00-puppet.pref',
          replace => true,
        }
      }
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
    file { '/etc/yum.repos.d/puppetlabs.repo':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      source  => 'puppet:///modules/openstack_project/centos-puppetlabs.repo',
      replace => true,
    }
  }

  file { '/etc/puppet/puppet.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('openstack_project/puppet.conf.erb'),
    replace => true,
  }

  service { 'puppet':
    ensure => stopped,
  }
}

# vim:sw=2:ts=2:expandtab:textwidth=79
