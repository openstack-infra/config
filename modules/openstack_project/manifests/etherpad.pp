class openstack_project::etherpad (
  $ssl_cert_file_contents = '',
  $ssl_key_file_contents = '',
  $ssl_chain_file_contents = '',
  $database_host = 'localhost',
  $database_password = '',
  $sysadmins = []
) {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [22, 80, 443],
    sysadmins                 => $sysadmins
  }

  include etherpad_lite
  include etherpad_lite::backup

  class { 'etherpad_lite::apache':
    ssl_cert_file           => '/etc/ssl/certs/etherpad.openstack.org.pem',
    ssl_key_file            => '/etc/ssl/private/etherpad.openstack.org.key',
    ssl_chain_file          => '/etc/ssl/certs/intermediate.pem',
    ssl_cert_file_contents  => $ssl_cert_file_contents,
    ssl_key_file_contents   => $ssl_key_file_contents,
    ssl_chain_file_contents => $ssl_chain_file_contents,
  }

  class { 'etherpad_lite::site':
    database_host => $database_host,
    database_password => $database_password,
  }

}

# vim:sw=2:ts=2:expandtab:textwidth=79
