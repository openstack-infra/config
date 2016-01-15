class openstack_project::infracloud::controller (
  $neutron_rabbit_password,
  $nova_rabbit_password,
  $root_mysql_password,
  $keystone_mysql_password,
  $glance_mysql_password,
  $neutron_mysql_password,
  $nova_mysql_password,
  $glance_admin_password,
  $keystone_admin_password,
  $neutron_admin_password,
  $nova_admin_password,
  $keystone_admin_token,
  $ssl_chain_file_contents,
  $keystone_ssl_key_file_contents,
  $keystone_ssl_cert_file_contents,
  $neutron_ssl_key_file_contents,
  $neutron_ssl_cert_file_contents,
  $glance_ssl_key_file_contents,
  $glance_ssl_cert_file_contents,
  $nova_ssl_key_file_contents,
  $nova_ssl_cert_file_contents,
  $controller_management_address,
  $controller_public_address = $::fqdn,
) {
  class { '::infracloud::controller':
    neutron_rabbit_password          => $neutron_rabbit_password,
    nova_rabbit_password             => $nova_rabbit_password,
    root_mysql_password              => $root_mysql_password,
    keystone_mysql_password          => $keystone_mysql_password,
    glance_mysql_password            => $glance_mysql_password,
    neutron_mysql_password           => $neutron_mysql_password,
    nova_mysql_password              => $nova_mysql_password,
    keystone_admin_password          => $keystone_admin_password,
    glance_admin_password            => $glance_admin_password,
    neutron_admin_password           => $neutron_admin_password,
    nova_admin_password              => $nova_admin_password,
    keystone_admin_token             => $keystone_admin_token,
    ssl_chain_file_contents          => $ssl_chain_file_contents,
    keystone_ssl_key_file_contents   => $keystone_ssl_key_file_contents,
    keystone_ssl_cert_file_contents  => $keystone_ssl_cert_file_contents,
    glance_ssl_key_file_contents     => $neutron_ssl_key_file_contents,
    glance_ssl_cert_file_contents    => $neutron_ssl_cert_file_contents,
    neutron_ssl_key_file_contents    => $glance_ssl_key_file_contents,
    neutron_ssl_cert_file_contents   => $glance_ssl_cert_file_contents,
    nova_ssl_key_file_contents       => $nova_ssl_key_file_contents,
    nova_ssl_cert_file_contents      => $nova_ssl_cert_file_contents,
    controller_public_address        => $controller_public_address,
    controller_management_address    => $controller_management_address,
  }

  realize (
    User::Virtual::Localuser['krinkle'],
    User::Virtual::Localuser['greghaynes'],
  }

}
