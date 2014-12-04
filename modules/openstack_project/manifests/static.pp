# == Class: openstack_project::static
#
class openstack_project::static (
  $sysadmins = [],
  $swift_authurl = '',
  $swift_user = '',
  $swift_key = '',
  $swift_tenant_name = '',
  $swift_region_name = '',
  $swift_default_container = '',
  $project_config_repo = '',
) {

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [22, 80, 443],
    sysadmins                 => $sysadmins,
  }

  class { 'project_config':
    url  => $project_config_repo,
  }

  include openstack_project
  class { 'jenkins::jenkinsuser':
    ssh_key => $openstack_project::jenkins_ssh_key,
  }

  include apache
  include apache::mod::wsgi

  a2mod { 'rewrite':
    ensure => present,
  }
  a2mod { 'proxy':
    ensure => present,
  }
  a2mod { 'proxy_http':
    ensure => present,
  }

  if ! defined(File['/srv/static']) {
    file { '/srv/static':
      ensure => directory,
    }
  }

  ###########################################################
  # Tarballs

  apache::vhost { 'tarballs.openstack.org':
    port     => 80,
    priority => '50',
    docroot  => '/srv/static/tarballs',
    require  => File['/srv/static/tarballs'],
  }

  file { '/srv/static/tarballs':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    require => User['jenkins'],
  }

  ###########################################################
  # CI

  apache::vhost { 'ci.openstack.org':
    port     => 80,
    priority => '50',
    docroot  => '/srv/static/ci',
    require  => File['/srv/static/ci'],
  }

  file { '/srv/static/ci':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    require => User['jenkins'],
  }

  ###########################################################
  # Logs

  openstack_project::log_server { "logs.openstack.org":
    domain => "openstack.org",
    jenkins_ssh_key => $openstack_project::jenkins_ssh_key,
    swift_authurl => $swift_authurl,
    swift_user => $swift_user,
    swift_key => $swift_key,
    swift_tenant_name => $swift_tenant_name,
    swift_region_name => $swift_region_name,
    swift_default_container => $swift_default_container,
  }

  ###########################################################
  # Docs-draft

  apache::vhost { 'docs-draft.openstack.org':
    port     => 80,
    priority => '50',
    docroot  => '/srv/static/docs-draft',
    require  => File['/srv/static/docs-draft'],
  }

  file { '/srv/static/docs-draft':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    require => User['jenkins'],
  }

  file { '/srv/static/docs-draft/robots.txt':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => 'puppet:///modules/openstack_project/disallow_robots.txt',
    require => File['/srv/static/docs-draft'],
  }

  class { 'openstack_project::pypi_mirror':
    vhost_name => 'pypi.openstack.org',
  }

  # Legacy pypi mirror
  file { '/srv/static/mirror/web/openstack':
    ensure  => absent,
    force   => true,
  }

  ###########################################################
  # Security

  apache::vhost { 'security.openstack.org':
    port     => 80,
    priority => '50',
    docroot  => '/srv/static/security',
    require  => File['/srv/static/security'],
  }

  file { '/srv/static/security':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    require => User['jenkins'],
  }

  ###########################################################
  # Governance

  apache::vhost { 'governance.openstack.org':
    port     => 80,
    priority => '50',
    docroot  => '/srv/static/governance',
    require  => File['/srv/static/governance'],
  }

  file { '/srv/static/governance':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    require => User['jenkins'],
  }

  ###########################################################
  # Specs

  apache::vhost { 'specs.openstack.org':
    port     => 80,
    priority => '50',
    docroot  => '/srv/static/specs',
    require  => File['/srv/static/specs'],
  }

  file { '/srv/static/specs':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    require => User['jenkins'],
  }

  file { '/srv/static/specs/index.html':
    ensure  => present,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0444',
    source  => $::project_config::specs_index_file,
    require => [File['/srv/static/specs'],
                $::project_config::config_dir],
  }

  ###########################################################
  # legacy summit.openstack.org site redirect

  apache::vhost { 'summit.openstack.org':
    port          => 80,
    priority      => '50',
    docroot       => 'MEANINGLESS_ARGUMENT',
    template      => 'openstack_project/summit.vhost.erb',
  }

  ###########################################################
  # legacy devstack.org site redirect

  apache::vhost { 'devstack.org':
    port          => 80,
    priority      => '50',
    docroot       => 'MEANINGLESS_ARGUMENT',
    serveraliases => ['*.devstack.org'],
    template      => 'openstack_project/devstack.vhost.erb',
  }
}
