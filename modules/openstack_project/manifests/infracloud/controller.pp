class openstack_project::infracloud::controller (
  $keystone_rabbit_password,
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
  $ssl_key_file_contents,
  $ssl_cert_file_contents,
  $br_name,
  $controller_management_address,
  $controller_public_address = $::fqdn,
  $openstackci_password,
  $openstackci_email = 'infra-root@openstack.org',
  $openstackjenkins_password,
  $openstackjenkins_email = 'infra-root@openstack.org',
  $neutron_subnet_cidr,
  $neutron_subnet_gateway,
  $neutron_subnet_allocation_pools,
) {
  class { '::infracloud::controller':
    keystone_rabbit_password         => $keystone_rabbit_password,
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
    ssl_key_file_contents            => $ssl_key_file_contents,
    ssl_cert_file_contents           => $ssl_cert_file_contents,
    br_name                          => $br_name,
    controller_management_address    => $controller_management_address,
    controller_public_address        => $controller_public_address,
    neutron_subnet_cidr              => $neutron_subnet_cidr,
    neutron_subnet_gateway           => $neutron_subnet_gateway,
    neutron_subnet_allocation_pools  => $neutron_subnet_allocation_pools,
  }

  keystone_domain { 'infra':
    ensure  => present,
    enabled => true,
  }

  keystone_tenant { 'openstackci':
    ensure      => present,
    enabled     => true,
    description => 'Infra Long Lived Resources',
    domain      => 'infra',
    require     => Keystone_domain['infra'],
  }

  keystone_tenant { 'openstackjenkins':
    ensure      => present,
    enabled     => true,
    description => 'Infra short lived resources',
    domain      => 'infra',
    require     => Keystone_domain['infra'],
  }

  keystone_user { 'openstackci':
    ensure   => present,
    enabled  => true,
    domain   => 'infra',
    email    => $openstackci_email,
    password => $openstackci_password,
    require  => Keystone_tenant['openstackci'],
  }

  keystone_user { 'openstackjenkins':
    ensure   => present,
    enabled  => true,
    domain   => 'infra',
    email    => $openstackjenkins_email,
    password => $openstackjenkins_password,
    require  => Keystone_tenant['openstackjenkins'],
  }
}
