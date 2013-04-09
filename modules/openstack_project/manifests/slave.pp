# == Class: openstack_project::slave
#
class openstack_project::slave (
  $bare = false,
  $certname = $::fqdn,
  $sysadmins = []
) {
  include openstack_project
  include openstack_project::tmpcleanup
  include openstack_project::automatic_upgrades
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [],
    certname                  => $certname,
    sysadmins                 => $sysadmins,
  }
  class { 'jenkins::slave':
    bare    => $bare,
    ssh_key => $openstack_project::jenkins_ssh_key,
  }
  class { 'salt':
    salt_master => 'ci-puppetmaster.openstack.org',
    minion_id   => $::fqdn,
  }
}
