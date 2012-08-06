class openstack_project::wiki($mysql_root_password) {

  include openssl
  include subversion

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80, 443]
  }

  realize (
    User::Virtual::Localuser["rlane"],
  )

  class { 'mediawiki':
    role => 'all',
    mediawiki_location => '/srv/mediawiki/w',
    site_hostname => $fqdn;
  }
  class { 'memcached':
    max_memory => 2048,
    listen_ip => '127.0.0.1',
    tcp_port => 11000,
    udp_port => 11000,
  }
  class {"mysql::server":
    config_hash => {
      'root_password' => "${mysql_root_password}",
      'default_engine' => 'InnoDB',
      'bind_address' => '127.0.0.1',
    }
  }
}
