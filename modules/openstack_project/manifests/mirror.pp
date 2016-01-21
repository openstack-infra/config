# == Class: openstack_project::mirror
#
class openstack_project::mirror (
  $vhost_name = $::fqdn,
) {

  $mirror_root = '/afs/openstack.org/mirror'
  $pypi_root = "${mirror_root}/pypi"
  $wheel_root = "${mirror_root}/wheel"
  $www_root = '/var/www/mirror'

  #####################################################
  # Build Apache Webroot
  file { "${www_root}":
    ensure  => directory,
    owner   => root,
    group   => root,
  }

  # Create the symlink to pypi.
  file { "${www_root}/pypi":
    ensure  => link,
    target  => "${pypi_root}/web",
    owner   => root,
    group   => root,
    require => [
      File["${www_root}"],
    ]
  }

  # Create the symlink to wheel.
  file { "${www_root}/wheel":
    ensure  => link,
    target  => "${wheel_root}",
    owner   => root,
    group   => root,
    require => [
      File["${www_root}"],
    ]
  }

  file { "${www_root}/robots.txt":
    ensure   => present,
    owner    => 'root',
    group    => 'root',
    mode     => '0444',
    source   => 'puppet:///modules/openstack_project/disallow_robots.txt',
    require  => File["${www_root}"],
  }

  #####################################################
  # Build VHost
  include ::httpd

  ::httpd::vhost { $vhost_name:
    port     => 80,
    priority => '50',
    docroot  => "${www_root}",
    template => 'openstack_project/mirror.vhost.erb',
    require  => [
      File["${www_root}"],
    ]
  }
}
