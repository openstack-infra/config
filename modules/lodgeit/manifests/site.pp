define lodgeit::site($port) {

  file { "/etc/nginx/sites-available/${name}":
    ensure => 'present',
    content => template("lodgeit/nginx.erb"),
    replace => 'true',
    require => Package[nginx]
  }

  file { "/etc/nginx/sites-enabled/${name}":
    ensure => link,
    target => "/etc/nginx/sites-available/${name}",
    require => Package[nginx]
  }

  file { "/etc/init/${name}-paste.conf":
    ensure => 'present',
    content => template("lodgeit/upstart.erb"),
    replace => 'true',
    require => Package[nginx]
  }

  file { "/srv/lodgeit/${name}":
    ensure => directory,
    recurse => true,
    source => "/tmp/lodgeit-main"
  }

# Database file needs replacing to be compatible with SQLAlchemy 0.7

  file { "/srv/lodgeit/${name}/lodgeit/database.py":
    replace => true,
    source => 'puppet:///modules/lodgeit/database.py'
  }

  file { "/srv/lodgeit/${name}/manage.py":
    mode => 755,
    replace => true,
    content => template("lodgeit/manage.py.erb")
  }

  file { "/srv/lodgeit/${name}/lodgeit/views/layout.html":
    replace => true,
    content => template("lodgeit/layout.html.erb")
  }

  exec { "create_database_${name}":
    command => "drizzle --user=root -e \"create database if not exists ${name};\"",
    path => "/bin:/usr/bin",
    require => Service["drizzle"]
  }

  service { "${name}-paste":
    provider => upstart,
    ensure => running,
    require => [Service["drizzle", "nginx"], Exec["create_database_${name}"]]
  }

}
