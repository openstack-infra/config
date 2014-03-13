# Class to configure puppetboard on a node.
# This will only work on the puppetdb server for now
class openstack_project::puppetboard(
  $basedir = $::puppetboard::params::basedir,
) {

  include apache

  class { 'apache::mod::wsgi': }

  class { '::puppetboard':
    enable_query => 'False', # This being a python false
  }

  $docroot = "${basedir}/puppetboard"

  # Template Uses:
  # - $basedir
  #
  file { "${docroot}/wsgi.py":
    ensure => present,
    content => template('puppetboard/wsgi.py.erb'),
    owner => $user,
    group => $group,
    require => User[$user],
  }

  apache::vhost { $::fqdn:
    port     => 80,
    docroot  => 'MEANINGLESS ARGUMENT',
    priority => '50',
    template => 'openstack_projects/puppetboard/puppetboard.vhost.erb',
  }

}
