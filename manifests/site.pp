#
# Default: should at least behave like an openstack server
#
node default {
  include openstack_project::puppet_cron
  class { 'openstack_project::server':
    sysadmins => hiera('sysadmins'),
  }
}

#
# Long lived servers:
#
node 'review.openstack.org' {
  class { 'openstack_project::review':
    github_oauth_token                  => hiera('gerrit_github_token'),
    github_project_username             => hiera('github_project_username'),
    github_project_password             => hiera('github_project_password'),
    mysql_password                      => hiera('gerrit_mysql_password'),
    mysql_root_password                 => hiera('gerrit_mysql_root_password'),
    email_private_key                   => hiera('gerrit_email_private_key'),
    gerritbot_password                  => hiera('gerrit_gerritbot_password'),
    ssl_cert_file_contents              => hiera('gerrit_ssl_cert_file_contents'),
    ssl_key_file_contents               => hiera('gerrit_ssl_key_file_contents'),
    ssl_chain_file_contents             => hiera('gerrit_ssl_chain_file_contents'),
    ssh_dsa_key_contents                => hiera('gerrit_ssh_dsa_key_contents'),
    ssh_dsa_pubkey_contents             => hiera('gerrit_ssh_dsa_pubkey_contents'),
    ssh_rsa_key_contents                => hiera('gerrit_ssh_rsa_key_contents'),
    ssh_rsa_pubkey_contents             => hiera('gerrit_ssh_rsa_pubkey_contents'),
    ssh_project_rsa_key_contents        => hiera('gerrit_project_ssh_rsa_key_contents'),
    ssh_project_rsa_pubkey_contents     => hiera('gerrit_project_ssh_rsa_pubkey_contents'),
    ssh_welcome_rsa_key_contents        => hiera('welcome_message_gerrit_ssh_private_key'),
    ssh_welcome_rsa_pubkey_contents     => hiera('welcome_message_gerrit_ssh_public_key'),
    ssh_replication_rsa_key_contents    => hiera('gerrit_replication_ssh_rsa_key_contents'),
    ssh_replication_rsa_pubkey_contents => hiera('gerrit_replication_ssh_rsa_pubkey_contents'),
    lp_sync_consumer_key                => hiera('gerrit_lp_consumer_key'),
    lp_sync_token                       => hiera('gerrit_lp_access_token'),
    lp_sync_secret                      => hiera('gerrit_lp_access_secret'),
    contactstore_appsec                 => hiera('gerrit_contactstore_appsec'),
    contactstore_pubkey                 => hiera('gerrit_contactstore_pubkey'),
    sysadmins                           => hiera('sysadmins'),
    swift_username                      => hiera('swift_store_user'),
    swift_password                      => hiera('swift_store_key'),
  }
}

node 'review-dev.openstack.org' {
  class { 'openstack_project::review_dev':
    github_oauth_token              => hiera('gerrit_dev_github_token'),
    github_project_username         => hiera('github_dev_project_username'),
    github_project_password         => hiera('github_dev_project_password'),
    mysql_password                  => hiera('gerrit_dev_mysql_password'),
    mysql_root_password             => hiera('gerrit_dev_mysql_root_password'),
    email_private_key               => hiera('gerrit_dev_email_private_key'),
    contactstore_appsec             => hiera('gerrit_dev_contactstore_appsec'),
    contactstore_pubkey             => hiera('gerrit_dev_contactstore_pubkey'),
    ssh_dsa_key_contents            => hiera('gerrit_dev_ssh_dsa_key_contents'),
    ssh_dsa_pubkey_contents         => hiera('gerrit_dev_ssh_dsa_pubkey_contents'),
    ssh_rsa_key_contents            => hiera('gerrit_dev_ssh_rsa_key_contents'),
    ssh_rsa_pubkey_contents         => hiera('gerrit_dev_ssh_rsa_pubkey_contents'),
    ssh_project_rsa_key_contents    => hiera('gerrit_dev_project_ssh_rsa_key_contents'),
    ssh_project_rsa_pubkey_contents => hiera('gerrit_dev_project_ssh_rsa_pubkey_contents'),
    lp_sync_consumer_key            => hiera('gerrit_dev_lp_consumer_key'),
    lp_sync_token                   => hiera('gerrit_dev_lp_access_token'),
    lp_sync_secret                  => hiera('gerrit_dev_lp_access_secret'),
    sysadmins                       => hiera('sysadmins'),
  }
}

node 'jenkins.openstack.org' {
  class { 'openstack_project::jenkins':
    jenkins_jobs_password   => hiera('jenkins_jobs_password'),
    jenkins_ssh_private_key => hiera('jenkins_ssh_private_key_contents'),
    ssl_cert_file_contents  => hiera('jenkins_ssl_cert_file_contents'),
    ssl_key_file_contents   => hiera('jenkins_ssl_key_file_contents'),
    ssl_chain_file_contents => hiera('jenkins_ssl_chain_file_contents'),
    sysadmins               => hiera('sysadmins'),
    zmq_event_receivers     => ['logstash.openstack.org',
                                'nodepool.openstack.org',
    ],
  }
}

node 'jenkins01.openstack.org' {
  class { 'openstack_project::jenkins':
    jenkins_jobs_password   => hiera('jenkins_jobs_password'),
    jenkins_ssh_private_key => hiera('jenkins_ssh_private_key_contents'),
    ssl_cert_file_contents  => hiera('jenkins01_ssl_cert_file_contents'),
    ssl_key_file_contents   => hiera('jenkins01_ssl_key_file_contents'),
    ssl_chain_file_contents => hiera('jenkins01_ssl_chain_file_contents'),
    sysadmins               => hiera('sysadmins'),
    zmq_event_receivers     => ['logstash.openstack.org',
                                'nodepool.openstack.org',
    ],
  }
}

node 'jenkins02.openstack.org' {
  class { 'openstack_project::jenkins':
    jenkins_jobs_password   => hiera('jenkins_jobs_password'),
    jenkins_ssh_private_key => hiera('jenkins_ssh_private_key_contents'),
    ssl_cert_file_contents  => hiera('jenkins02_ssl_cert_file_contents'),
    ssl_key_file_contents   => hiera('jenkins02_ssl_key_file_contents'),
    ssl_chain_file_contents => hiera('jenkins02_ssl_chain_file_contents'),
    sysadmins               => hiera('sysadmins'),
    zmq_event_receivers     => ['logstash.openstack.org',
                                'nodepool.openstack.org',
    ],
  }
}

node 'jenkins03.openstack.org' {
  class { 'openstack_project::jenkins':
    jenkins_jobs_password   => hiera('jenkins_jobs_password'),
    jenkins_ssh_private_key => hiera('jenkins_ssh_private_key_contents'),
    ssl_cert_file_contents  => hiera('jenkins03_ssl_cert_file_contents'),
    ssl_key_file_contents   => hiera('jenkins03_ssl_key_file_contents'),
    ssl_chain_file_contents => hiera('jenkins03_ssl_chain_file_contents'),
    sysadmins               => hiera('sysadmins'),
    zmq_event_receivers     => ['logstash.openstack.org',
                                'nodepool.openstack.org',
    ],
  }
}

node 'jenkins04.openstack.org' {
  class { 'openstack_project::jenkins':
    jenkins_jobs_password   => hiera('jenkins_jobs_password'),
    jenkins_ssh_private_key => hiera('jenkins_ssh_private_key_contents'),
    ssl_cert_file_contents  => hiera('jenkins04_ssl_cert_file_contents'),
    ssl_key_file_contents   => hiera('jenkins04_ssl_key_file_contents'),
    ssl_chain_file_contents => hiera('jenkins04_ssl_chain_file_contents'),
    sysadmins               => hiera('sysadmins'),
    zmq_event_receivers     => ['logstash.openstack.org',
                                'nodepool.openstack.org',
    ],
  }
}

node 'jenkins05.openstack.org' {
  class { 'openstack_project::jenkins':
    jenkins_jobs_password   => hiera('jenkins_jobs_password'),
    jenkins_ssh_private_key => hiera('jenkins_ssh_private_key_contents'),
    ssl_cert_file_contents  => hiera('jenkins05_ssl_cert_file_contents'),
    ssl_key_file_contents   => hiera('jenkins05_ssl_key_file_contents'),
    ssl_chain_file_contents => hiera('jenkins05_ssl_chain_file_contents'),
    sysadmins               => hiera('sysadmins'),
    zmq_event_receivers     => ['logstash.openstack.org',
                                'nodepool.openstack.org',
    ],
  }
}

node 'jenkins06.openstack.org' {
  class { 'openstack_project::jenkins':
    jenkins_jobs_password   => hiera('jenkins_jobs_password'),
    jenkins_ssh_private_key => hiera('jenkins_ssh_private_key_contents'),
    ssl_cert_file_contents  => hiera('jenkins06_ssl_cert_file_contents'),
    ssl_key_file_contents   => hiera('jenkins06_ssl_key_file_contents'),
    ssl_chain_file_contents => hiera('jenkins06_ssl_chain_file_contents'),
    sysadmins               => hiera('sysadmins'),
    zmq_event_receivers     => ['logstash.openstack.org',
                                'nodepool.openstack.org',
    ],
  }
}

node 'jenkins07.openstack.org' {
  class { 'openstack_project::jenkins':
    jenkins_jobs_password   => hiera('jenkins_jobs_password'),
    jenkins_ssh_private_key => hiera('jenkins_ssh_private_key_contents'),
    ssl_cert_file_contents  => hiera('jenkins07_ssl_cert_file_contents'),
    ssl_key_file_contents   => hiera('jenkins07_ssl_key_file_contents'),
    ssl_chain_file_contents => hiera('jenkins07_ssl_chain_file_contents'),
    sysadmins               => hiera('sysadmins'),
    zmq_event_receivers     => ['logstash.openstack.org',
                                'nodepool.openstack.org',
    ],
  }
}

node 'jenkins-dev.openstack.org' {
  class { 'openstack_project::jenkins_dev':
    jenkins_ssh_private_key  => hiera('jenkins_dev_ssh_private_key_contents'),
    sysadmins                => hiera('sysadmins'),
    mysql_password           => hiera('nodepool_dev_mysql_password'),
    mysql_root_password      => hiera('nodepool_dev_mysql_root_password'),
    nodepool_ssh_private_key => hiera('jenkins_dev_ssh_private_key_contents'),
    jenkins_api_user         => hiera('jenkins_dev_api_user'),
    jenkins_api_key          => hiera('jenkins_dev_api_key'),
    jenkins_credentials_id   => hiera('jenkins_dev_credentials_id'),
    hpcloud_username         => hiera('nodepool_hpcloud_username'),
    hpcloud_password         => hiera('nodepool_hpcloud_password'),
    hpcloud_project          => hiera('nodepool_hpcloud_project'),
  }
}

node 'cacti.openstack.org' {
  include openstack_project::ssl_cert_check
  class { 'openstack_project::cacti':
    sysadmins => hiera('sysadmins'),
  }
}

node 'community.openstack.org' {
  class { 'openstack_project::community':
    sysadmins => hiera('sysadmins'),
  }
}

node 'ci-puppetmaster.openstack.org' {
  class { 'openstack_project::puppetmaster':
    sysadmins => hiera('sysadmins'),
  }
}

node 'puppetmaster.openstack.org' {
  class { 'openstack_project::puppetmaster':
    sysadmins => hiera('sysadmins'),
    version   => 3,
  }
}

node 'puppetdb.openstack.org' {
  class { 'openstack_project::puppetdb':
    sysadmins => hiera('sysadmins'),
  }
}

node 'graphite.openstack.org' {
  class { 'openstack_project::graphite':
    sysadmins               => hiera('sysadmins'),
    graphite_admin_user     => hiera('graphite_admin_user'),
    graphite_admin_email    => hiera('graphite_admin_email'),
    graphite_admin_password => hiera('graphite_admin_password'),
    statsd_hosts            => ['logstash.openstack.org',
                                'nodepool.openstack.org',
                                'zuul.openstack.org'],
  }
}

node 'groups.openstack.org' {
  class { 'openstack_project::groups':
    sysadmins => hiera('sysadmins'),
  }
}

node 'groups-dev.openstack.org' {
  class { 'openstack_project::groups_dev':
    sysadmins           => hiera('sysadmins'),
    site_admin_password => hiera('groups_dev_site_admin_password'),
    site_mysql_host     => hiera('groups_dev_site_mysql_host'),
    site_mysql_password => hiera('groups_dev_site_mysql_password'),
  }
}

node 'lists.openstack.org' {
  class { 'openstack_project::lists':
    listadmins   => hiera('listadmins'),
    listpassword => hiera('listpassword'),
  }
}

node 'paste.openstack.org' {
  class { 'openstack_project::paste':
    sysadmins => hiera('sysadmins'),
  }
}

node 'planet.openstack.org' {
  class { 'openstack_project::planet':
    sysadmins => hiera('sysadmins'),
  }
}

node 'eavesdrop.openstack.org' {
  class { 'openstack_project::eavesdrop':
    nickpass                => hiera('openstack_meetbot_password'),
    sysadmins               => hiera('sysadmins'),
    statusbot_nick          => hiera('statusbot_nick'),
    statusbot_password      => hiera('statusbot_nick_password'),
    statusbot_server        => 'chat.freenode.net',
    statusbot_channels      => 'edeploy, fuel-dev, heat, magnetodb, murano, openstack, openstack-101, openstack-anvil, openstack-bacon, openstack-barbican, openstack-board, openstack-ceilometer, openstack-chef, openstack-cinder, openstack-climate, openstack-cloudkeep, openstack-community, openstack-dev, openstack-dns, openstack-doc, openstack-entropy, openstack-foundation, openstack-gantt, openstack-gate, openstack-hyper-v, openstack-infra, openstack-ironic, openstack-keystone, openstack-manila, openstack-marconi, openstack-meeting, openstack-meeting-3, openstack-meeting-alt, openstack-meniscus, openstack-merges, openstack-metering, openstack-neutron, openstack-nova, openstack-opw, openstack-oslo, openstack-packaging, openstack-qa, openstack-raksha, openstack-relmgr-office, openstack-sdks, openstack-state-management, openstack-swift, openstack-translation, openstack-trove, packstack-dev, refstack, storyboard, syscompass, tripleo',
    statusbot_auth_nicks    => 'jeblair, ttx, fungi, mordred, clarkb, sdague, SergeyLukjanov',
    statusbot_wiki_user     => hiera('statusbot_wiki_username'),
    statusbot_wiki_password => hiera('statusbot_wiki_password'),
    statusbot_wiki_url      => 'https://wiki.openstack.org/w/api.php',
    statusbot_wiki_pageid   => '1781',
    accessbot_nick          => hiera('accessbot_nick'),
    accessbot_password      => hiera('accessbot_nick_password'),
  }
}

node 'etherpad.openstack.org' {
  class { 'openstack_project::etherpad':
    ssl_cert_file_contents  => hiera('etherpad_ssl_cert_file_contents'),
    ssl_key_file_contents   => hiera('etherpad_ssl_key_file_contents'),
    ssl_chain_file_contents => hiera('etherpad_ssl_chain_file_contents'),
    mysql_host              => hiera('etherpad_db_host'),
    mysql_user              => hiera('etherpad_db_user'),
    mysql_password          => hiera('etherpad_db_password'),
    sysadmins               => hiera('sysadmins'),
  }
}

node 'etherpad-dev.openstack.org' {
  class { 'openstack_project::etherpad_dev':
    mysql_host          => hiera('etherpad-dev_db_host'),
    mysql_user          => hiera('etherpad-dev_db_user'),
    mysql_password      => hiera('etherpad-dev_db_password'),
    sysadmins           => hiera('sysadmins'),
  }
}

node 'activity-dev.openstack.org' {
  class { 'openstack_project::activity_dev':
    sysadmins               => hiera('sysadmins'),
    site_admin_password     => hiera('activity_dev_site_admin_password'),
    site_mysql_host         => hiera('activity_dev_site_mysql_host'),
    site_mysql_password     => hiera('activity_dev_site_mysql_password'),
  }
}

node 'wiki.openstack.org' {
  class { 'openstack_project::wiki':
    mysql_root_password     => hiera('wiki_db_password'),
    sysadmins               => hiera('sysadmins'),
    ssl_cert_file_contents  => hiera('wiki_ssl_cert_file_contents'),
    ssl_key_file_contents   => hiera('wiki_ssl_key_file_contents'),
    ssl_chain_file_contents => hiera('wiki_ssl_chain_file_contents'),
  }
}

node 'puppet-dashboard.openstack.org' {
  class { 'openstack_project::dashboard':
    password        => hiera('dashboard_password'),
    mysql_password  => hiera('dashboard_mysql_password'),
    sysadmins       => hiera('sysadmins'),
  }
}

$elasticsearch_nodes = [
  'elasticsearch01.openstack.org',
  'elasticsearch02.openstack.org',
  'elasticsearch03.openstack.org',
  'elasticsearch04.openstack.org',
  'elasticsearch05.openstack.org',
  'elasticsearch06.openstack.org',
]

node 'logstash.openstack.org' {
  class { 'openstack_project::logstash':
    sysadmins                       => hiera('sysadmins'),
    elasticsearch_nodes             => $elasticsearch_nodes,
    gearman_workers                 => [
      'logstash-worker01.openstack.org',
      'logstash-worker02.openstack.org',
      'logstash-worker03.openstack.org',
      'logstash-worker04.openstack.org',
      'logstash-worker05.openstack.org',
      'logstash-worker06.openstack.org',
      'logstash-worker07.openstack.org',
      'logstash-worker08.openstack.org',
      'logstash-worker09.openstack.org',
      'logstash-worker10.openstack.org',
      'logstash-worker11.openstack.org',
      'logstash-worker12.openstack.org',
      'logstash-worker13.openstack.org',
      'logstash-worker14.openstack.org',
      'logstash-worker15.openstack.org',
      'logstash-worker16.openstack.org',
    ],
    discover_nodes                  => [
      'elasticsearch01.openstack.org:9200',
      'elasticsearch02.openstack.org:9200',
      'elasticsearch03.openstack.org:9200',
      'elasticsearch04.openstack.org:9200',
      'elasticsearch05.openstack.org:9200',
      'elasticsearch06.openstack.org:9200',
    ],
  }
}

node /^logstash-worker\d+\.openstack\.org$/ {
  class { 'openstack_project::logstash_worker':
    sysadmins           => hiera('sysadmins'),
    elasticsearch_nodes => $elasticsearch_nodes,
    discover_node       => 'elasticsearch01.openstack.org',
  }
}

node /^elasticsearch\d+\.openstack\.org$/ {
  class { 'openstack_project::elasticsearch_node':
    sysadmins             => hiera('sysadmins'),
    elasticsearch_nodes   => $elasticsearch_nodes,
    elasticsearch_clients => [
      'logstash.openstack.org',
      'logstash-worker01.openstack.org',
      'logstash-worker02.openstack.org',
      'logstash-worker03.openstack.org',
      'logstash-worker04.openstack.org',
      'logstash-worker05.openstack.org',
      'logstash-worker06.openstack.org',
      'logstash-worker07.openstack.org',
      'logstash-worker08.openstack.org',
      'logstash-worker09.openstack.org',
      'logstash-worker10.openstack.org',
      'logstash-worker11.openstack.org',
      'logstash-worker12.openstack.org',
      'logstash-worker13.openstack.org',
      'logstash-worker14.openstack.org',
      'logstash-worker15.openstack.org',
      'logstash-worker16.openstack.org',
    ],
    discover_nodes        => $elasticsearch_nodes,
  }
}

# A CentOS machine to load balance git access.
node 'git.openstack.org' {
  class { 'openstack_project::git':
    sysadmins               => hiera('sysadmins'),
    balancer_member_names   => [
      'git01.openstack.org',
      'git02.openstack.org',
      'git03.openstack.org',
      'git04.openstack.org',
      'git05.openstack.org',
    ],
    balancer_member_ips     => [
      '198.61.223.164',
      '23.253.102.209',
      '162.242.144.38',
      '166.78.46.164',
      '166.78.46.121',
    ],
  }
}

# CentOS machines to run cgit and git daemon. Will be
# load balanced by git.openstack.org.
node /^git\d+\.openstack\.org$/ {
  include openstack_project
  class { 'openstack_project::git_backend':
    vhost_name              => 'git.openstack.org',
    sysadmins               => hiera('sysadmins'),
    git_gerrit_ssh_key      => hiera('gerrit_replication_ssh_rsa_pubkey_contents'),
    git_zuul_ssh_key        => $openstack_project::jenkins_ssh_key,
    ssl_cert_file_contents  => hiera('git_ssl_cert_file_contents'),
    ssl_key_file_contents   => hiera('git_ssl_key_file_contents'),
    ssl_chain_file_contents => hiera('git_ssl_chain_file_contents'),
    behind_proxy            => true,
  }
}

# A machine to run ODSREG in preparation for summits.
node 'summit.openstack.org' {
  class { 'openstack_project::summit':
    sysadmins => hiera('sysadmins'),
  }
}

# A machine to run Storyboard
node 'storyboard.openstack.org' {
  class { 'openstack_project::storyboard':
    sysadmins               => hiera('sysadmins'),
    mysql_host              => hiera('storyboard_db_host'),
    mysql_user              => hiera('storyboard_db_user'),
    mysql_password          => hiera('storyboard_db_password'),
    ssl_cert_file_contents  => hiera('storyboard_ssl_cert_file_contents'),
    ssl_key_file_contents   => hiera('storyboard_ssl_key_file_contents'),
    ssl_chain_file_contents => hiera('storyboard_ssl_chain_file_contents'),
  }
}

# A machine to serve static content.
node 'static.openstack.org' {
  class { 'openstack_project::static':
    sysadmins => hiera('sysadmins'),
  }
}

# A machine to serve various project status updates.
node 'status.openstack.org' {
  class { 'openstack_project::status':
    sysadmins                     => hiera('sysadmins'),
    gerrit_host                   => 'review.openstack.org',
    gerrit_ssh_host_key           => hiera('gerrit_ssh_rsa_pubkey_contents'),
    reviewday_ssh_public_key      => hiera('reviewday_rsa_pubkey_contents'),
    reviewday_ssh_private_key     => hiera('reviewday_rsa_key_contents'),
    releasestatus_ssh_public_key  => hiera('releasestatus_rsa_pubkey_contents'),
    releasestatus_ssh_private_key => hiera('releasestatus_rsa_key_contents'),
    recheck_ssh_public_key        => hiera('elastic-recheck_gerrit_ssh_public_key'),
    recheck_ssh_private_key       => hiera('elastic-recheck_gerrit_ssh_private_key'),
    recheck_bot_nick              => 'openstackrecheck',
    recheck_bot_passwd            => hiera('elastic-recheck_ircbot_password'),
  }
}

node 'nodepool.openstack.org' {
  class { 'openstack_project::nodepool':
    mysql_password           => hiera('nodepool_mysql_password'),
    mysql_root_password      => hiera('nodepool_mysql_root_password'),
    nodepool_ssh_private_key => hiera('jenkins_ssh_private_key_contents'),
    sysadmins                => hiera('sysadmins'),
    statsd_host              => 'graphite.openstack.org',
    jenkins_api_user         => hiera('jenkins_api_user'),
    jenkins_api_key          => hiera('jenkins_api_key'),
    jenkins_credentials_id   => hiera('jenkins_credentials_id'),
    rackspace_username       => hiera('nodepool_rackspace_username'),
    rackspace_password       => hiera('nodepool_rackspace_password'),
    rackspace_project        => hiera('nodepool_rackspace_project'),
    hpcloud_username         => hiera('nodepool_hpcloud_username'),
    hpcloud_password         => hiera('nodepool_hpcloud_password'),
    hpcloud_project          => hiera('nodepool_hpcloud_project'),
    tripleo_username         => hiera('nodepool_tripleo_username'),
    tripleo_password         => hiera('nodepool_tripleo_password'),
    tripleo_project          => hiera('nodepool_tripleo_project'),
  }
}

node 'zuul.openstack.org' {
  class { 'openstack_project::zuul_prod':
    gerrit_server        => 'review.openstack.org',
    gerrit_user          => 'jenkins',
    gerrit_ssh_host_key  => hiera('gerrit_ssh_rsa_pubkey_contents'),
    zuul_ssh_private_key => hiera('jenkins_ssh_private_key_contents'),
    url_pattern          => 'http://logs.openstack.org/{build.parameters[LOG_PATH]}',
    zuul_url             => 'http://zuul.openstack.org/p',
    sysadmins            => hiera('sysadmins'),
    statsd_host          => 'graphite.openstack.org',
    gearman_workers      => [
      'nodepool.openstack.org',
      'jenkins.openstack.org',
      'jenkins01.openstack.org',
      'jenkins02.openstack.org',
      'jenkins03.openstack.org',
      'jenkins04.openstack.org',
      'jenkins05.openstack.org',
      'jenkins06.openstack.org',
      'jenkins07.openstack.org',
      'jenkins-dev.openstack.org',
      'zm01.openstack.org',
      'zm02.openstack.org',
    ],
  }
}

node 'zm01.openstack.org' {
  class { 'openstack_project::zuul_merger':
    gearman_server       => 'zuul.openstack.org',
    gerrit_server        => 'review.openstack.org',
    gerrit_user          => 'jenkins',
    gerrit_ssh_host_key  => hiera('gerrit_ssh_rsa_pubkey_contents'),
    zuul_ssh_private_key => hiera('jenkins_ssh_private_key_contents'),
    sysadmins            => hiera('sysadmins'),
  }
}

node 'zm02.openstack.org' {
  class { 'openstack_project::zuul_merger':
    gearman_server       => 'zuul.openstack.org',
    gerrit_server        => 'review.openstack.org',
    gerrit_user          => 'jenkins',
    gerrit_ssh_host_key  => hiera('gerrit_ssh_rsa_pubkey_contents'),
    zuul_ssh_private_key => hiera('jenkins_ssh_private_key_contents'),
    sysadmins            => hiera('sysadmins'),
  }
}

node 'zuul-dev.openstack.org' {
  class { 'openstack_project::zuul_dev':
    gerrit_server        => 'review-dev.openstack.org',
    gerrit_user          => 'zuul-dev',
    zuul_ssh_private_key => hiera('zuul_dev_ssh_private_key_contents'),
    url_pattern          => 'http://logs.openstack.org/{build.parameters[LOG_PATH]}',
    zuul_url             => 'http://zuul-dev.openstack.org/p',
    sysadmins            => hiera('sysadmins'),
    statsd_host          => 'graphite.openstack.org',
    gearman_workers      => [
      'jenkins.openstack.org',
      'jenkins01.openstack.org',
      'jenkins02.openstack.org',
      'jenkins03.openstack.org',
      'jenkins04.openstack.org',
      'jenkins05.openstack.org',
      'jenkins06.openstack.org',
      'jenkins07.openstack.org',
      'jenkins-dev.openstack.org',
    ],
  }
}

node 'pbx.openstack.org' {
  class { 'openstack_project::pbx':
    sysadmins     => hiera('sysadmins'),
    sip_providers => [
      {
        provider => 'voipms',
        hostname => 'dallas.voip.ms',
        username => hiera('voipms_username'),
        password => hiera('voipms_password'),
        outgoing => false,
      },
    ],
  }
}

# A backup machine.  Don't run cron or puppet agent on it.
node /^ci-backup-.*\.openstack\.org$/ {
  include openstack_project::backup_server
}

#
# Jenkins slaves:
#

node 'mirror26.slave.openstack.org' {
  include openstack_project
  class { 'openstack_project::mirror26_slave':
    jenkins_ssh_public_key  => $openstack_project::jenkins_ssh_key,
    jenkins_ssh_private_key => hiera('jenkins_ssh_private_key_contents')
  }
}

node 'mirror27.slave.openstack.org' {
  include openstack_project
  class { 'openstack_project::mirror27_slave':
    jenkins_ssh_public_key  => $openstack_project::jenkins_ssh_key,
    jenkins_ssh_private_key => hiera('jenkins_ssh_private_key_contents')
  }
}

node 'mirror33.slave.openstack.org' {
  include openstack_project
  class { 'openstack_project::mirror33_slave':
    jenkins_ssh_public_key  => $openstack_project::jenkins_ssh_key,
    jenkins_ssh_private_key => hiera('jenkins_ssh_private_key_contents')
  }
}

node 'proposal.slave.openstack.org' {
  include openstack_project
  class { 'openstack_project::proposal_slave':
    transifex_username      => 'openstackjenkins',
    transifex_password      => hiera('transifex_password'),
    jenkins_ssh_public_key  => $openstack_project::jenkins_ssh_key,
    jenkins_ssh_private_key => hiera('jenkins_ssh_private_key_contents'),
  }
}

node 'pypi.slave.openstack.org' {
  include openstack_project
  class { 'openstack_project::pypi_slave':
    pypi_username          => 'openstackci',
    pypi_password          => hiera('pypi_password'),
    jenkins_ssh_public_key => $openstack_project::jenkins_ssh_key,
    jenkinsci_username     => hiera('jenkins_ci_org_user'),
    jenkinsci_password     => hiera('jenkins_ci_org_password'),
    mavencentral_username  => hiera('mavencentral_org_user'),
    mavencentral_password  => hiera('mavencentral_org_password'),
  }
}

node 'salt-trigger.slave.openstack.org' {
  include openstack_project
  class { 'openstack_project::salt_trigger_slave':
    jenkins_ssh_public_key => $openstack_project::jenkins_ssh_key,
  }
}

node /^precise-?\d+.*\.slave\.openstack\.org$/ {
  include openstack_project
  include openstack_project::puppet_cron
  class { 'openstack_project::slave':
    certname  => 'precise.slave.openstack.org',
    ssh_key   => $openstack_project::jenkins_ssh_key,
    sysadmins => hiera('sysadmins'),
  }
}

node /^precise-dev\d+.*\.slave\.openstack\.org$/ {
  include openstack_project
  include openstack_project::puppet_cron
  class { 'openstack_project::slave':
    ssh_key   => $openstack_project::jenkins_dev_ssh_key,
    sysadmins => hiera('sysadmins'),
  }
}

node /^precisepy3k-?\d+.*\.slave\.openstack\.org$/ {
  include openstack_project
  include openstack_project::puppet_cron
  class { 'openstack_project::slave':
    ssh_key      => $openstack_project::jenkins_ssh_key,
    sysadmins    => hiera('sysadmins'),
    python3      => true,
    include_pypy => true,
  }
}

node /^precisepy3k-dev\d+.*\.slave\.openstack\.org$/ {
  include openstack_project
  include openstack_project::puppet_cron
  class { 'openstack_project::slave':
    ssh_key      => $openstack_project::jenkins_dev_ssh_key,
    sysadmins    => hiera('sysadmins'),
    python3      => true,
    include_pypy => true,
  }
}

node /^centos6-?\d+\.slave\.openstack\.org$/ {
  include openstack_project
  include openstack_project::puppet_cron
  class { 'openstack_project::slave':
    certname  => 'centos6.slave.openstack.org',
    ssh_key   => $openstack_project::jenkins_ssh_key,
    sysadmins => hiera('sysadmins'),
  }
}

node /^centos6-dev\d+\.slave\.openstack\.org$/ {
  include openstack_project
  include openstack_project::puppet_cron
  class { 'openstack_project::slave':
    ssh_key   => $openstack_project::jenkins_dev_ssh_key,
    sysadmins => hiera('sysadmins'),
  }
}

node /^fedora18-?\d+\.slave\.openstack\.org$/ {
  include openstack_project
  include openstack_project::puppet_cron
  class { 'openstack_project::slave':
    certname  => 'fedora18.slave.openstack.org',
    ssh_key   => $openstack_project::jenkins_ssh_key,
    sysadmins => hiera('sysadmins'),
    python3   => true,
  }
}

node /^fedora18-dev\d+\.slave\.openstack\.org$/ {
  include openstack_project
  include openstack_project::puppet_cron
  class { 'openstack_project::slave':
    ssh_key   => $openstack_project::jenkins_dev_ssh_key,
    sysadmins => hiera('sysadmins'),
    python3   => true,
  }
}

node 'openstackid-dev.openstack.org' {
  class { 'openstack_project::openstackid_dev':
    sysadmins               => hiera('sysadmins'),
    site_admin_password     => hiera('openstackid_dev_site_admin_password'),
    id_mysql_host           => hiera('openstackid_dev_id_mysql_host'),
    id_mysql_password       => hiera('openstackid_dev_id_mysql_password'),
    ss_mysql_host           => hiera('openstackid_dev_ss_mysql_host'),
    ss_mysql_password       => hiera('openstackid_dev_ss_mysql_password'),
    redis_password          => hiera('openstackid_dev_redis_password'),
    ssl_cert_file_contents  => hiera('openstackid_dev_ssl_cert_file_contents'),
    ssl_key_file_contents   => hiera('openstackid_dev_ssl_key_file_contents'),
    ssl_chain_file_contents => hiera('openstackid_dev_ssl_chain_file_contents'),
  }
}

# vim:sw=2:ts=2:expandtab:textwidth=79
