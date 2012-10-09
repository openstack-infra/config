class salt (
  $master = $::fqdn
) {
  include apt

  apt::ppa { 'ppa:saltstack/salt': }

  package { 'python-software-properties':
    ensure => present,
  }

  package { 'salt-minion':
    ensure  => present,
    require => Apt::Ppa['ppa:saltstack/salt'],
  }

  file { '/etc/salt/minion':
    ensure => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('salt/minion.erb'),
    replace => true,
    require => Package['salt-minion'],
  }
}
