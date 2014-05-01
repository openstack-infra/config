# == Class: openstack_project::single_use_slave
#
# This class configures single use Jenkins slaves with a few
# toggleable options. Most importantly sudo rights for the Jenkins
# user are by default off but can be enabled. Also, automatic_upgrades
# are off by default as the assumption is the backing image for
# this single use slaves will be refreshed with new packages
# periodically.
class openstack_project::single_use_slave (
  $certname = $::fqdn,
  $install_users = true,
  $sudo = false,
  $bare = true,
  $python3 = false,
  $include_pypy = false,
  $automatic_upgrades = false,
  $all_mysql_privs = false,
  $enable_unbound = true,
  $ssh_key = $openstack_project::jenkins_ssh_key
) inherits openstack_project {
  class { 'openstack_project::template':
    certname           => $certname,
    automatic_upgrades => $automatic_upgrades,
    install_users      => $install_users,
    enable_unbound     => $enable_unbound,
    iptables_rules4    =>
      [
        # Ports 69 and 6385 allow to allow ironic VM nodes to reach tftp and
        # the ironic API from the neutron public net
        '-p udp --dport 69 -s 172.24.4.0/24 -j ACCEPT',
        '-p tcp --dport 6385 -s 172.24.4.0/24 -j ACCEPT',
        # Ports 8000, 8003, 8004 from the devstack neutron public net to allow
        # nova servers to reach heat-api-cfn, heat-api-cloudwatch, heat-api
        '-p tcp --dport 8000 -s 172.24.4.0/24 -j ACCEPT',
        '-p tcp --dport 8003 -s 172.24.4.0/24 -j ACCEPT',
        '-p tcp --dport 8004 -s 172.24.4.0/24 -j ACCEPT',
      ],
  }
  class { 'jenkins::slave':
    ssh_key         => $ssh_key,
    sudo            => $sudo,
    bare            => $bare,
    python3         => $python3,
    include_pypy    => $include_pypy,
    all_mysql_privs => $all_mysql_privs,
  }
}
