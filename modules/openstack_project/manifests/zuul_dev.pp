# == Class: openstack_project::zuul_dev
#
class openstack_project::zuul_dev(
  $vhost_name = $::fqdn,
  $gearman_server = '127.0.0.1',
  $gerrit_server = '',
  $gerrit_user = '',
  $gerrit_ssh_host_key = '',
  $gerrit_ssh_host_identity = [
    'review-dev.openstack.org',
    '23.253.78.13',
    '2001:4800:7817:101:be76:4eff:fe04',
  ],
  $zuul_ssh_private_key = '',
  $url_pattern = '',
  $status_url = 'http://zuul-dev.openstack.org',
  $zuul_url = '',
  $sysadmins = [],
  $statsd_host = '',
  $gearman_workers = [],
  $project_config_repo = '',
) {

  realize (
    User::Virtual::Localuser['zaro'],
  )

  # Turn a list of hostnames into a list of iptables rules
  $iptables_rules = regsubst ($gearman_workers, '^(.*)$', '-m state --state NEW -m tcp -p tcp --dport 4730 -s \1 -j ACCEPT')

  # Create known_hosts_content
  $known_hosts_content = inline_template('<%= (@gerrit_ssh_host_identity).join(",") %> <%= @gerrit_ssh_host_key %>')

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80],
    iptables_rules6           => $iptables_rules,
    iptables_rules4           => $iptables_rules,
    sysadmins                 => $sysadmins,
  }

  class { 'openstackci::zuul_scheduler':
    vhost_name               => $vhost_name,
    gearman_server           => $gearman_server,
    gerrit_server            => $gerrit_server,
    gerrit_user              => $gerrit_user,
    known_hosts_content      => $known_hosts_content,
    zuul_ssh_private_key     => $zuul_ssh_private_key,
    url_pattern              => $url_pattern,
    zuul_url                 => $zuul_url,
    job_name_in_report       => true,
    status_url               => $status_url,
    statsd_host              => $statsd_host,
    git_email                => 'jenkins@openstack.org',
    git_name                 => 'OpenStack Jenkins',
    project_config_repo      => $project_config_repo,
    project_config_base      => 'dev/',
  }

  class { 'openstackci::zuul_merger':
    manage_common_zuul => false,
  }
}
