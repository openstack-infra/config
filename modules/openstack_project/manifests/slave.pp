class openstack_project::slave(
  $certname=$fqdn
  ) {
  include openstack_project
  include tmpreaper
  include unattended_upgrades
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [],
    certname => $cername,
  }
  class { 'jenkins::slave':
    ssh_key => $openstack_project::jenkins_ssh_key
  }
}


