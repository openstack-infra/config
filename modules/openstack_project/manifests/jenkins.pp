# == Class: openstack_project::jenkins
#
class openstack_project::jenkins (
  $jenkins_jobs_password = '',
  $manage_jenkins_jobs = true,
  $ssl_cert_file_contents = '',
  $ssl_key_file_contents = '',
  $ssl_chain_file_contents = '',
  $jenkins_ssh_private_key = '',
  $sysadmins = []
) {
  include openstack_project

  $logstash_workers = [
    'logstash-worker1.openstack.org',
    'logstash-worker2.openstack.org',
    'logstash-worker3.openstack.org',
  ]
  $iptables_rule = regsubst ($logstash_workers, '^(.*)$', '-m state --state NEW -m tcp -p tcp --dport 8888 -s \1 -j ACCEPT')
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80, 443],
    iptables_rules6           => $iptables_rule,
    iptables_rules4           => $iptables_rule,
    sysadmins                 => $sysadmins,
  }

  $vhost_name = 'jenkins.openstack.org'
  class { '::jenkins::master':
    vhost_name              => $vhost_name,
    serveradmin             => 'webmaster@openstack.org',
    logo                    => 'openstack.png',
    ssl_cert_file           => '/etc/ssl/certs/jenkins.openstack.org.pem',
    ssl_key_file            => '/etc/ssl/private/jenkins.openstack.org.key',
    ssl_chain_file          => '/etc/ssl/certs/intermediate.pem',
    ssl_cert_file_contents  => $ssl_cert_file_contents,
    ssl_key_file_contents   => $ssl_key_file_contents,
    ssl_chain_file_contents => $ssl_chain_file_contents,
    jenkins_ssh_private_key => $jenkins_ssh_private_key,
    jenkins_ssh_public_key  => $openstack_project::jenkins_ssh_key,
  }

  if $manage_jenkins_jobs == true {
    class { '::jenkins::job_builder':
      url      => "https://${vhost_name}/",
      username => 'gerrig', # This is not a typo, well it isn't anymore.
      password => $jenkins_jobs_password,
    }

    file { '/etc/jenkins_jobs/config':
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      recurse => true,
      source  =>
        'puppet:///modules/openstack_project/jenkins_job_builder/config',
      notify  => Exec['jenkins_jobs_update'],
    }

    file { '/etc/default/jenkins':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => 'puppet:///modules/openstack_project/jenkins/jenkins.default',
    }
  }
}
