class openstack_project::dashboard(
    $password = '',
    $mysql_password = '',
    $sysadmins = []
) {

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80, 443, 3000],
    sysadmins                 => $sysadmins
  }

  class { '::dashboard':
    dashboard_ensure    => 'present',
    dashboard_user      => 'www-data',
    dashboard_group     => 'www-data',
    dashboard_password  => $password,
    dashboard_db        => 'dashboard_prod',
    dashboard_charset   => 'utf8',
    dashboard_site      => $::fqdn,
    dashboard_port      => '3000',
    mysql_root_pw       => $mysql_password,
    passenger           => true,
    dashboard_config    => 'echo "innodb_file_per_table=1" >> /etc/my.cnf'
  }
}

# vim:sw=2:ts=2:expandtab:textwidth=79
