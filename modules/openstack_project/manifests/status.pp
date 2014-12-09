# == Class: openstack_project::status
#
class openstack_project::status (
  $sysadmins = [],
  $gerrit_host,
  $gerrit_ssh_host_key,
  $reviewday_ssh_public_key = '',
  $reviewday_ssh_private_key = '',
  $releasestatus_ssh_public_key = '',
  $releasestatus_ssh_private_key = '',
  $recheck_ssh_public_key,
  $recheck_ssh_private_key,
  $recheck_bot_passwd,
  $recheck_bot_nick,
  $vhost_index = 'status.openstack.org',
  $jquery_visibility_git_url = 'https://github.com/mathiasbynens/jquery-visibility.git',
  $jquery_graphite_git_url = 'https://github.com/prestontimmons/graphitejs.git',
  $jquery_flot_git_url = 'https://github.com/flot/flot.git',
  $reviewday_git_url = 'git://git.openstack.org/openstack-infra/reviewday',
  $reviewday_serveradmin = 'webmaster@openstack.org',
  $reviewday_gerrit_url = 'review.openstack.org',
  $reviewday_gerrit_port = '29418',
  $reviewday_gerrit_user = 'reviewday',
  $bugdaystats_git_url = 'git://git.openstack.org/openstack-infra/bugdaystats',
  $bugdaystats_serveradmin = 'webmaster@openstack.org',
) {

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [22, 80, 443],
    sysadmins                 => $sysadmins,
  }

  include openstack_project
  class { 'jenkins::jenkinsuser':
    ssh_key => $openstack_project::jenkins_ssh_key,
  }

  include apache

  a2mod { 'rewrite':
    ensure => present,
  }
  a2mod { 'proxy':
    ensure => present,
  }
  a2mod { 'proxy_http':
    ensure => present,
  }

  file { '/srv/static':
    ensure => directory,
  }

  ###########################################################
  # Status - Index

  apache::vhost { '${vhost_index}':
    port     => 80,
    priority => '50',
    docroot  => '/srv/static/status',
    template => 'openstack_project/status.vhost.erb',
    require  => File['/srv/static/status'],
  }

  file { '/srv/static/status':
    ensure => directory,
  }

  package { 'libjs-jquery':
    ensure => present,
  }

  package { 'yui-compressor':
    ensure => present,
  }

  file { '/srv/static/status/index.html':
    ensure  => present,
    source  => 'puppet:///modules/openstack_project/status/index.html',
    require => File['/srv/static/status'],
  }

  file { '/srv/static/status/favicon.ico':
    ensure  => present,
    source  => 'puppet:///modules/openstack_project/status/favicon.ico',
    require => File['/srv/static/status'],
  }

  file { '/srv/static/status/common.js':
    ensure  => present,
    source  => 'puppet:///modules/openstack_project/status/common.js',
    require => File['/srv/static/status'],
  }

  file { '/srv/static/status/jquery.min.js':
    ensure  => link,
    target  => '/usr/share/javascript/jquery/jquery.min.js',
    require => [File['/srv/static/status'],
                Package['libjs-jquery']],
  }

  vcsrepo { '/opt/jquery-visibility':
    ensure   => latest,
    provider => git,
    revision => 'master',
    source   => $jquery_visibility_git_url,
  }

  exec { 'install_jquery-visibility' :
    command     => 'yui-compressor -o /srv/static/status/jquery-visibility.min.js /opt/jquery-visibility/jquery-visibility.js',
    path        => '/bin:/usr/bin',
    refreshonly => true,
    subscribe   => Vcsrepo['/opt/jquery-visibility'],
    require     => [File['/srv/static/status'],
                    Vcsrepo['/opt/jquery-visibility']],
  }

  vcsrepo { '/opt/jquery-graphite':
    ensure   => latest,
    provider => git,
    revision => 'master',
    source   => $jquery_graphite_git_url,
  }

  file { '/srv/static/status/jquery-graphite.js':
    ensure  => link,
    target  => '/opt/jquery-graphite/jquery.graphite.js',
    require => [File['/srv/static/status'],
                Vcsrepo['/opt/jquery-graphite']],
  }
  vcsrepo { '/opt/flot':
    ensure   => latest,
    provider => git,
    revision => 'master',
    source   => $jquery_flot_git_url,
  }

  exec { 'install_flot' :
    command     => 'yui-compressor -o \'.js$:.min.js\' /opt/flot/jquery.flot*.js; mv /opt/flot/jquery.flot*.min.js /srv/static/status',
    path        => '/bin:/usr/bin',
    refreshonly => true,
    subscribe   => Vcsrepo['/opt/flot'],
    require     => [File['/srv/static/status'],
                    Vcsrepo['/opt/flot']],
  }

  ###########################################################
  # Status - elastic-recheck
  include elastic_recheck

  class { 'elastic_recheck::bot':
    gerrit_host             => $gerrit_host,
    gerrit_ssh_host_key     => $gerrit_ssh_host_key,
    recheck_ssh_public_key  => $recheck_ssh_public_key,
    recheck_ssh_private_key => $recheck_ssh_private_key,
    recheck_bot_passwd      => $recheck_bot_passwd,
    recheck_bot_nick        => $recheck_bot_nick,
  }

  # sets up the cron update scripts for static pages
  include elastic_recheck::cron

  ###########################################################
  # Status - zuul

  file { '/srv/static/status/zuul':
    ensure => directory,
  }

  file { '/srv/static/status/zuul/index.html':
    ensure  => present,
    source  => 'puppet:///modules/openstack_project/zuul/status.html',
    require => File['/srv/static/status/zuul'],
  }

  file { '/srv/static/status/zuul/status.js':
    ensure  => present,
    source  => 'puppet:///modules/openstack_project/zuul/status.js',
    require => File['/srv/static/status/zuul'],
  }

  file { '/srv/static/status/zuul/green.png':
    ensure  => present,
    source  => 'puppet:///modules/openstack_project/zuul/green.png',
    require => File['/srv/static/status/zuul'],
  }

  file { '/srv/static/status/zuul/red.png':
    ensure  => present,
    source  => 'puppet:///modules/openstack_project/zuul/red.png',
    require => File['/srv/static/status/zuul'],
  }

  file { '/srv/static/status/zuul/black.png':
    ensure  => present,
    source  => 'puppet:///modules/openstack_project/zuul/black.png',
    require => File['/srv/static/status/zuul'],
  }

  file { '/srv/static/status/zuul/grey.png':
    ensure  => present,
    source  => 'puppet:///modules/openstack_project/zuul/grey.png',
    require => File['/srv/static/status/zuul'],
  }

  file { '/srv/static/status/zuul/line-angle.png':
    ensure  => present,
    source  => 'puppet:///modules/openstack_project/zuul/line-angle.png',
    require => File['/srv/static/status/zuul'],
  }

  file { '/srv/static/status/zuul/line-t.png':
    ensure  => present,
    source  => 'puppet:///modules/openstack_project/zuul/line-t.png',
    require => File['/srv/static/status/zuul'],
  }

  file { '/srv/static/status/zuul/line.png':
    ensure  => present,
    source  => 'puppet:///modules/openstack_project/zuul/line.png',
    require => File['/srv/static/status/zuul'],
  }


  ###########################################################
  # Status - reviewday

  include reviewday

  reviewday::site { 'reviewday':
    git_url                       => $reviewday_git_url,
    serveradmin                   => $reviewday_serveradmin,
    httproot                      => '/srv/static/reviewday',
    gerrit_url                    => $reviewday_gerrit_url,
    gerrit_port                   => $reviewday_gerrit_port,
    gerrit_user                   => $reviewday_gerrit_user,
    reviewday_gerrit_ssh_key      => $gerrit_ssh_host_key,
    reviewday_rsa_pubkey_contents => $reviewday_ssh_public_key,
    reviewday_rsa_key_contents    => $reviewday_ssh_private_key,
  }

  ###########################################################
  # Status - releasestatus

  class { 'releasestatus':
    releasestatus_prvkey_contents => $releasestatus_ssh_private_key,
    releasestatus_pubkey_contents => $releasestatus_ssh_public_key,
    releasestatus_gerrit_ssh_key  => $gerrit_ssh_host_key,
  }

  releasestatus::site { 'releasestatus':
    configfile => 'integrated.yaml',
    httproot   => '/srv/static/release',
  }
  ###########################################################
  # Status - bugdaystats

  include bugdaystats

  bugdaystats::site { 'bugdaystats':
    git_url     => $bugdaystats_git_url,
    serveradmin => $bugdaystats_serveradmin,
    httproot    => '/srv/static/bugdaystats',
    configfile  => '/var/lib/bugdaystats/config.js',
  }
}
