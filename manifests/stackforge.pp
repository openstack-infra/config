import "openstack"

class stackforge_jenkins_slave {
  include tmpreaper
  class { 'openstack_server':
    iptables_public_tcp_ports => []
  }
  class { 'jenkins_slave':
    ssh_key => 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvlHx1TM9y6Y+oWJwPQP1jDejQYLA5MaTgD2oQOgQapSAWWU3f9/xcKKF4I5cC833xrSqFCqpstuWt5FdtO6qL5KMqGeVOwTCgcH0uGHciSF/zxBVpHp2n3rHLb0Fibyz/ys2kI+9J/hD0+GlVNQ/U8h9PZPMLFoJIZz5ep5WBszLM5z4vymBZ3GeytD8hk1BW0GLYi9vYWFrwoCTH6o6xRtdKajNE/9NcRGXjkY+SW7EGvqTAfLdsQ8q23MIO2ZX6YOpnmxAmR3OyNEOMo7Y/XCWjqTGWhQ669YaFxagS65f7EGCGwhhgQPtReDwkW88yTGhU3fZjS6Rc3BymTsnx jenkins@jenkins.stackforge.org'
  }
}

#
# Default: should at least behave like an openstack server
#

node default {
  class { 'openstack_template':
    iptables_public_tcp_ports => []
  }
}

#
# Long lived servers:
#
node "puppet.stackforge.org" {
  class { 'openstack_server':
    iptables_public_tcp_ports => [8140]
  }
}

node "review.stackforge.org" {
  class { 'openstack_server':
    iptables_public_tcp_ports => [80, 443, 29418]
  }
  class { 'gerrit':
    virtual_hostname => 'review.stackforge.org',
    canonicalweburl => "https://review.stackforge.org/",
    ssl_cert_file => '/etc/ssl/certs/review.stackforge.org.crt',
    ssl_key_file => '/etc/ssl/private/review.stackforge.org.key',
    ssl_chain_file => '/etc/ssl/certs/intermediate.crt',
    email => "review@stackforge.org",
    github_projects => [ {
                         name => 'stackforge/MRaaS',
                         close_pull => 'true'
                         }, {
                         name => 'stackforge/reddwarf',
                         close_pull => 'true'
                         } ],
    logo => 'stackforge.png',
    war => 'http://ci.openstack.org/tarballs/gerrit-2.3-5-gaec571e.war',
  }
}

node "jenkins.stackforge.org" {
  class { 'openstack_server':
    iptables_public_tcp_ports => [80, 443, 4155]
  }
  class { 'jenkins_master':
    serveradmin => 'webmaster@stackforge.org',
    site => 'jenkins.stackforge.org',
    logo => 'stackforge.png'
  }

  class { "jenkins_jobs":
    site => "stackforge",
  }

  jenkins_jobs::python_jobs { "reddwarf-natty":
    site => "stackforge",
    project => "reddwarf",
    node_group => "natty"
  }

  jenkins_jobs::generic_jobs { "reddwarf":
    site => "stackforge",
    project => "reddwarf",
    node_group => "oneiric"
  }
}

#
# Jenkins slaves:
#
node /^build.*\.slave\.stackforge\.org$/ {
  include stackforge_jenkins_slave
}

