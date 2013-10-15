# == Class: jeepyb
#
class jeepyb (
  $git_source_repo = 'https://git.openstack.org/openstack-infra/jeepyb',
) {
  include mysql::python

  if ! defined(Package['python-paramiko']) {
    package { 'python-paramiko':
      ensure   => present,
    }
  }

  if ! defined(Package['PyGithub']) {
    package { 'PyGithub':
      ensure   => latest,
      provider => pip2,
      require  => Class['pip::python2'],
    }
  }

  if ! defined(Package['gerritlib']) {
    package { 'gerritlib':
      ensure   => latest,
      provider => pip2,
      require  => Class['pip::python2'],
    }
  }

  if ! defined(Package['pkginfo']) {
    package { 'pkginfo':
      ensure   => latest,
      provider => pip2,
      require  => Class['pip::python2'],
    }
  }

  package { 'gcc':
    ensure => present,
  }

  # A lot of things need yaml, be conservative requiring this package to avoid
  # conflicts with other modules.
  case $::osfamily {
    'Debian': {
      if ! defined(Package['python-yaml']) {
        package { 'python-yaml':
          ensure => present,
        }
      }
    }
    'RedHat': {
      if ! defined(Package['PyYAML']) {
        package { 'PyYAML':
          ensure => present,
        }
      }
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} The 'jeepyb' module only supports osfamily Debian or RedHat.")
    }
  }

  vcsrepo { '/opt/jeepyb':
    ensure   => latest,
    provider => git,
    revision => 'master',
    source   => $git_source_repo,
  }

  exec { 'install_jeepyb' :
    command     => 'pip install -U /opt/jeepyb',
    refreshonly => true,
    require     => Class['mysql::python'],
    subscribe   => Vcsrepo['/opt/jeepyb'],
  }
}
