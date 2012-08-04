class openstack_project::jenkins($jenkins_jobs_password) {

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80, 443, 4155]
  }
  class { '::jenkins::master':
    site => 'jenkins.openstack.org',
    serveradmin => 'webmaster@openstack.org',
    logo => 'openstack.png',
    ssl_cert_file => '/etc/ssl/certs/jenkins.openstack.org.pem',
    ssl_key_file => '/etc/ssl/private/jenkins.openstack.org.key',
    ssl_chain_file => '/etc/ssl/certs/intermediate.pem',
  }
  class { "::jenkins::job_builder":
    url => "https://jenkins.openstack.org/",
    username => "gerrig",
    password => $jenkins_jobs_password,
    site => "openstack",
  }
  file { "/etc/default/jenkins":
    ensure => 'present',
    source => 'puppet:///modules/openstack_project/jenkins/jenkins.default'
  }

}
