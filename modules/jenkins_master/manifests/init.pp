class jenkins_master($vhost_name=$fqdn,
      $serveradmin="webmaster@$fqdn",
      $logo,
      $ssl_cert_file='',
      $ssl_key_file='',
      $ssl_chain_file=''
  ) {

  include pip
  include apt
  include apache

  #This key is at http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key
  apt::key { "jenkins":
    key        => "D50582E6",
    key_source => "http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key",
    require    => Package["wget"]
  }

  apt::source { 'jenkins':
    location => "http://pkg.jenkins-ci.org/debian",
    release => "binary/",
    repos => "",
    require => Apt::Key['jenkins'],
    notify => Class['Apt::Update']
  }

  apache::vhost { $vhost_name:
    port => 443,
    docroot => 'MEANINGLESS ARGUMENT',
    priority => '50',
    template => 'jenkins_master/jenkins.vhost.erb',
    ssl => true,
  }
  a2mod { 'rewrite':
    ensure => present
  }
  a2mod { 'proxy':
    ensure => present
  }
  a2mod { 'proxy_http':
    ensure => present
  }

  $packages = [
    "python-babel",
    "wget",
  ]

  package { $packages:
    ensure => "present",
  }

  package { "jenkins":
    ensure => "present",
    require => Apt::Source['jenkins'],
  }

  service { "versions":
    provider => upstart,
    ensure => running,
  }

  file { '/etc/init/versions.conf':
    owner => 'root',
    group => 'root',
    mode => 444,
    ensure => 'present',
    source => "puppet:///modules/jenkins_master/versions.conf",
    replace => 'true',
    notify => Service["versions"]
  }

  package { "apache-libcloud":
    ensure => present,
    provider => pip,
    require => Class[pip]
  }

  package { "git-review":
    ensure => latest,
    provider => pip,
    require => Class[pip]
  }

  package { "tox":
    ensure => latest,  # okay to use latest for pip
    provider => pip,
    require => Class[pip],
  }

  exec { "update apt cache":
    subscribe => [ File["/etc/apt/sources.list.d/jenkins.list"]],
    refreshonly => true,
    path => "/bin:/usr/bin",
    command => "apt-get update",
  }

  file { "/var/lib/jenkins/plugins/simple-theme-plugin":
    ensure => directory,
    owner => 'jenkins',
    group => 'nogroup'
  }

  file { "/var/lib/jenkins/plugins/simple-theme-plugin/openstack.css":
    ensure => present,
    source => "puppet:///modules/jenkins_master/openstack.css",
    require => File["/var/lib/jenkins/plugins/simple-theme-plugin"]
  }

  file { "/var/lib/jenkins/plugins/simple-theme-plugin/openstack.js":
    ensure => present,
    content => template("jenkins_master/openstack.js.erb"),
    require => File["/var/lib/jenkins/plugins/simple-theme-plugin"]
  }

  file { "/var/lib/jenkins/plugins/simple-theme-plugin/openstack-page-bkg.jpg":
    ensure => present,
    source => "puppet:///modules/jenkins_master/openstack-page-bkg.jpg",
    require => File["/var/lib/jenkins/plugins/simple-theme-plugin"]
  }

  file { "/var/lib/jenkins/plugins/simple-theme-plugin/title.png":
    ensure => present,
    source => "puppet:///modules/jenkins_master/${logo}",
    require => File["/var/lib/jenkins/plugins/simple-theme-plugin"]
  }

  file { '/usr/local/jenkins':
    owner => 'root',
    group => 'root',
    mode => 755,
    ensure => 'directory',
  }

  file { '/usr/local/jenkins/slave_scripts':
    owner => 'root',
    group => 'root',
    mode => 755,
    ensure => 'directory',
    recurse => true,
    require => File['/usr/local/jenkins'],
    source => [
                "puppet:///modules/jenkins_slave/slave_scripts",
              ],
  }
}
