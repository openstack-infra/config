class unattended_upgrades($ensure = present) {
  package { 'unattended-upgrades':
    ensure => $ensure,
  }

  package { 'mailutils':
    ensure => $ensure,
  }

  file { '/etc/apt/apt.conf.d/10periodic':
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => 'puppet:///modules/unattended_upgrades/10periodic',
    replace => true,
  }

  file { '/etc/apt/apt.conf.d/50unattended-upgrades':
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => 'puppet:///modules/unattended_upgrades/50unattended-upgrades',
    replace => true,
  }
}
