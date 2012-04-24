define meetbot::site($nick, $network, $server, $url, $channels, $use_ssl) {

  file { "/var/lib/meetbot/${name}":
    ensure => directory,
    owner => 'meetbot',
    require => File["/var/lib/meetbot"]
  }

  file { "/var/lib/meetbot/${name}/conf":
    ensure => directory,
    owner => 'meetbot',
    require => File["/var/lib/meetbot/${name}"]
  }

  file { "/var/lib/meetbot/${name}/data":
    ensure => directory,
    owner => 'meetbot',
    require => File["/var/lib/meetbot/${name}"]
  }

  file { "/var/lib/meetbot/${name}/data/tmp":
    ensure => directory,
    owner => 'meetbot',
    require => File["/var/lib/meetbot/${name}/data"]
  }

  file { "/var/lib/meetbot/${name}/backup":
    ensure => directory,
    owner => 'meetbot',
    require => File["/var/lib/meetbot/${name}"]
  }

  file { "/var/lib/meetbot/${name}/logs":
    ensure => directory,
    owner => 'meetbot',
    require => File["/var/lib/meetbot/${name}"]
  }

  file { "/var/lib/meetbot/${name}.conf":
    ensure => present,
    content => template("meetbot/supybot.conf.erb"),
    owner => 'meetbot',
    require => File["/var/lib/meetbot"],
    notify => Service["${name}-meetbot"]
  }

  file { "/var/lib/meetbot/${name}/ircmeeting":
    ensure => directory,
    recurse => true,
    source => "/tmp/meetbot/ircmeeting",
    owner => 'meetbot',
    require => File["/var/lib/meetbot/${name}"]
  }

  file { "/var/lib/meetbot/${name}/ircmeeting/meetingLocalConfig.py":
    ensure => present,
    content => template("meetbot/meetingLocalConfig.py.erb"),
    owner => 'meetbot',
    require => File["/var/lib/meetbot/${name}/ircmeeting"],
    notify => Service["${name}-meetbot"]
  }

# we set this file as root ownership because meetbot overwrites it on shutdown
# this means when puppet changes it and restarts meetbot the file is reset

  file { "/etc/init/${name}-meetbot.conf":
    ensure => 'present',
    content => template("meetbot/upstart.erb"),
    replace => 'true',
    require => File["/var/lib/meetbot/${name}.conf"],
    owner => 'root',
    notify => Service["${name}-meetbot"]
  }

  service { "${name}-meetbot":
    provider => upstart,
    ensure => running,
    require => File["/etc/init/${name}-meetbot.conf"]
  }
}
