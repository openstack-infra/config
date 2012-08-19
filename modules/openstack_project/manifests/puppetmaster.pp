class openstack_project::puppetmaster(
  $port
  ) {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [$port]
  }
  package {"puppetmaster-passenger":
    ensure => present,
  }
  cron { "updatepuppetmaster":
    user => root,
    minute => "*/15",
    command => 'sleep $((RANDOM\%600)) && cd /opt/openstack-ci-puppet/production && /usr/bin/git pull -q && /bin/bash install_modules.sh',
    environment => "PATH=/var/lib/gems/1.8/bin:/usr/bin:/bin:/usr/sbin:/sbin",
  }

  file { '/etc/puppet/hiera.yaml':
    owner => 'root',
    group => 'root',
    mode => 555,
    ensure => 'present',
    source => 'puppet:///modules/openstack_project/puppetmaster/hiera.yaml',
    replace => 'true',
    require => Class['openstack_project::server']
  }

  apache::vhost { $fqdn:
    port => $port,
    docroot => 'MEANINGLESS ARGUMENT',
    priority => '50',
    template => 'openstack_project/puppetmasterr/vhost.erb',
    ssl => true,
  }
}
