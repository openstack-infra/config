class exim(
  $mailman_domains = [],
  $smarthost = '',
  $sysadmin = []
) {

  include exim::params

  package { $::exim::params::package:
    ensure => present,
  }

  if ($::osfamily == 'RedHat') {
    service { 'postfix':
      ensure      => stopped
    }
  }

  service { 'exim':
    ensure      => running,
    name        => $::exim::params::service_name,
    hasrestart  => true,
    subscribe   => File[$::exim::params::config_file],
    require     => Package[$::exim::params::package],
  }

  file { $::exim::params::config_file:
    ensure  => present,
    content => template("${module_name}/exim4.conf.erb"),
    group   => 'root',
    mode    => '0444',
    owner   => 'root',
    replace => true,
    require => Package[$::exim::params::package],
  }

  file { '/etc/aliases':
    ensure  => present,
    content => template("${module_name}/aliases.erb"),
    group   => 'root',
    mode    => '0444',
    owner   => 'root',
    replace => true,
  }
}

# vim:sw=2:ts=2:expandtab:textwidth=79
