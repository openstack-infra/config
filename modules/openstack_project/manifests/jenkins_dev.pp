class openstack_project::jenkins_dev {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80, 443, 4155]
  } 
  class { 'backup':
    backup_user => 'bup-jenkins-dev',
    backup_server => 'ci-backup-rs-ord.openstack.org'
  }
  class { 'jenkins_master':
    vhost_name => 'jenkins-dev.openstack.org',
    serveradmin => 'webmaster@openstack.org',
    logo => 'openstack.png',
    ssl_cert_file => '/etc/ssl/certs/ssl-cert-snakeoil.pem',
    ssl_key_file => '/etc/ssl/private/ssl-cert-snakeoil.key',
    ssl_chain_file => '',
  }
}
