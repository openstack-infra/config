# == Class: openstack_project::single_use_slave
#
# This class configures single use Jenkins slaves with a few
# toggleable options. Most importantly sudo rights for the Jenkins
# user are by default off but can be enabled.
class openstack_project::single_use_slave (
  $certname = $::fqdn,
  $install_users = false,
  $install_resolv_conf = true,
  $sudo = false,
  $ssh_key = $openstack_project::jenkins_ssh_key,
  $jenkins_gitfullname = 'OpenStack Jenkins',
  $jenkins_gitemail = 'jenkins@openstack.org',
) inherits openstack_project {
  class { 'openstack_project::template':
    certname                  => $certname,
    install_users             => $install_users,
    install_resolv_conf       => $install_resolv_conf,
  }

  include ::haveged

  class { '::jenkins::jenkinsuser':
    ssh_key     => $ssh_key,
    gitfullname => $jenkins_gitfullname,
    gitemail    => $jenkins_gitemail,
  }
}
