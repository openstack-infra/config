class gerritbot(
  $nick,
  $password,
  $server,
  $user,
  $vhost_name
) {

  include pip

  package { 'gerritbot':
    ensure   => latest,  # we want the latest from pip
    provider => pip,
    require  => Class[pip]
  }

  file { '/etc/init.d/gerritbot':
    owner   => 'root',
    group   => 'root',
    mode    => 555,
    ensure  => 'present',
    source  => 'puppet:///modules/gerritbot/gerritbot.init',
    require => Package['gerritbot'],
  }

  service { 'gerritbot':
    name       => 'gerritbot',
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => File['/etc/init.d/gerritbot'],
    subscribe  => [Package['gerritbot'],
                   File['/home/gerrit2/gerritbot_channel_config.yaml']],
  }

  file { '/home/gerrit2/gerritbot_channel_config.yaml':
    owner   => 'root',
    group   => 'gerrit2',
    mode    => 440,
    ensure  => 'present',
    source  => 'puppet:///modules/gerritbot/gerritbot_channel_config.yaml',
    replace => true,
    require => User['gerrit2'],
  }

  file { '/home/gerrit2/gerritbot.config':
    owner   => 'root',
    group   => 'gerrit2',
    mode    => 440,
    ensure  => 'present',
    content => template('gerritbot/gerritbot.config.erb'),
    replace => 'true',
    require => User['gerrit2']
  }

}
