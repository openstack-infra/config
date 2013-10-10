# Class: pip::python3
#
class pip::python3 {
  include pip::params
  include pip::bootstrap

  package { $::pip::params::python3_devel_package:
    ensure => present,
  }

  package { $::pip::params::python3_pip_package:
    ensure  => absent,
  }

  package { $::pip::params::python3_setuptools_package:
    ensure => absent,
  }

  exec { 'install_pip':
    command   => 'python3 /var/lib/python-install/get-pip.py',
    path      => '/bin:/usr/bin',
    subscribe => Downloader[$::pip::params::get_pip_url],
    creates   => $::pip::params::pip_executable,
  }
}
