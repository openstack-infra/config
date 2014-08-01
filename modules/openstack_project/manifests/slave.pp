# == Class: openstack_project::slave
#
class openstack_project::slave (
  $thin = false,
  $certname = $::fqdn,
  $ssh_key = '',
  $sysadmins = [],
  $python3 = false,
  $include_pypy = false
) {

  include openstack_project
  include openstack_project::automatic_upgrades
  include openstack_project::tmpcleanup

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [],
    certname                  => $certname,
    sysadmins                 => $sysadmins,
  }

  class { 'jenkins::slave':
    python3      => $python3,
  }

  class { 'openstack_project::jenkinsuser':
    ssh_key         => $ssh_key,
  }

  include jenkins::cgroups
  include ulimit
  ulimit::conf { 'limit_jenkins_procs':
    limit_domain => 'jenkins',
    limit_type   => 'hard',
    limit_item   => 'nproc',
    limit_value  => '256'
  }

  class { 'openstack_project::slave_common':
    include_pypy => $include_pypy,
  }

  if (! $thin) {
    include openstack_project::thick_slave
  }

}
