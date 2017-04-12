# == Class: openstack_project::slave_common
#
# Common configuration between openstack_project::slave and
# openstack_project::single_use_slave
class openstack_project::slave_common(
){
  vcsrepo { '/opt/requirements':
    ensure   => latest,
    provider => git,
    revision => 'master',
    source   => 'https://git.openstack.org/openstack/requirements',
  }

  file { '/home/jenkins/.pydistutils.cfg':
    ensure  => present,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0644',
    source  => 'puppet:///modules/openstack_project/pydistutils.cfg',
    require => Class['jenkins::jenkinsuser'],
  }

  # needed by jenkins/jobs
  if ! defined(Package['curl']) {
    package { 'curl':
      ensure => present,
    }
  }

  # install linux-headers depending on OS version
  case $::osfamily {
    'RedHat': {

      if ! defined(Package['kernel-devel']) {
        package { 'kernel-devel':
          ensure => present,
        }
      }

      if ! defined(Package['kernel-headers']) {
        package { 'kernel-headers':
          ensure => present,
        }
      }
    }
    'Debian': {
      if ($::operatingsystem == 'Debian') {
        # install depending on architecture
        case $::architecture {
          'amd64', 'x86_64': {
            $headers_package = ['linux-headers-amd64']
          }
          'x86': {
            $headers_package = ['linux-headers-686-pae']
          }
          default: {
            $headers_package = ["linux-headers-${::kernelrelease}"]
          }
        }
        if ! defined(Package[$headers_package]) {
          package { $headers_package:
            ensure => present,
          }
        }
      }
      else {
        if ($::lsbdistcodename == 'precise') {
          if ! defined(Package['linux-headers-virtual']) {
            package { 'linux-headers-virtual':
              ensure => present,
            }
          }
          if ! defined(Package['linux-headers-generic']) {
            package { 'linux-headers-generic':
              ensure => present,
            }
          }
        }
        else {
          # In trusty (and later), linux-headers-virtual is a transitional package that
          # simply depends on linux-headers-generic, so there is no need to specify it
          # any more.  Specifying it when installing on an arm64 host causes an error,
          # as linux-headers-virtual does not exist for arm64/aarch64.
          if ! defined(Package['linux-headers-generic']) {
            package { 'linux-headers-generic':
              ensure => present,
            }
          }
        }
      }
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily}.")
    }
  }

  vcsrepo { '/opt/zuul':
    ensure   => latest,
    provider => git,
    revision => 'master',
    source   => 'https://git.openstack.org/openstack-infra/zuul.git',
  }

  python::virtualenv { '/usr/zuul-env':
    ensure       => present,
    owner        => 'root',
    group        => 'root',
    timeout      => 0,
  }

  exec { 'zuul-env-update':
    command     => '/usr/zuul-env/bin/pip --log /usr/zuul-env/pip.log install /opt/zuul',
    refreshonly => true,
    subscribe   => Vcsrepo['/opt/zuul'],
    require     => Python::Virtualenv['/usr/zuul-env'],
  }
}
