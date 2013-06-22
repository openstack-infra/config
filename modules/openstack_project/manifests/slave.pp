# == Class: openstack_project::slave
#
class openstack_project::slave (
  $bare = false,
  $certname = $::fqdn,
  $ssh_key = '',
  $sysadmins = [],
  $python3 = false
) {
  include openstack_project
  include openstack_project::tmpcleanup
  include openstack_project::automatic_upgrades
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [],
    certname                  => $certname,
    sysadmins                 => $sysadmins,
  }
  if ($python3 == true and $::lsbdistcodename == 'precise') {
    apt::ppa { 'ppa:zulcss/py3k': }
  }
  class { 'jenkins::slave':
    bare    => $bare,
    ssh_key => $ssh_key,
    python3 => $python3,
  }
  class { 'salt':
    salt_master => 'ci-puppetmaster.openstack.org',
  }
  include jenkins::cgroups
  include ulimit
  ulimit::conf { 'limit_jenkins_procs':
    limit_domain => 'jenkins',
    limit_type   => 'hard',
    limit_item   => 'nproc',
    limit_value  => '256'
  }
}
