#
# Top-level variables
#
# There must not be any whitespace between this comment and the variables or
# in between any two variables in order for them to be correctly parsed and
# passed around in test.sh
#
$elasticsearch_nodes = hiera_array('elasticsearch_nodes')

#
# Default: should at least behave like an openstack server
#
node default {
  class { 'openstack_project::server':
    sysadmins => hiera('sysadmins', []),
  }
}

#
# Long lived servers:
#
# Node-OS: trusty
node 'review.openstack.org' {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80, 443, 29418],
    sysadmins                 => hiera('sysadmins', []),
  }

  class { 'openstack_project::review':
    project_config_repo                 => 'https://git.openstack.org/openstack-infra/project-config',
    github_oauth_token                  => hiera('gerrit_github_token'),
    github_project_username             => hiera('github_project_username', 'username'),
    github_project_password             => hiera('github_project_password'),
    mysql_host                          => hiera('gerrit_mysql_host', 'localhost'),
    mysql_password                      => hiera('gerrit_mysql_password'),
    email_private_key                   => hiera('gerrit_email_private_key'),
    token_private_key                   => hiera('gerrit_rest_token_private_key'),
    gerritbot_password                  => hiera('gerrit_gerritbot_password'),
    gerritbot_ssh_rsa_key_contents      => hiera('gerritbot_ssh_rsa_key_contents'),
    gerritbot_ssh_rsa_pubkey_contents   => hiera('gerritbot_ssh_rsa_pubkey_contents'),
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
    lp_access_token                     => hiera('gerrit_lp_access_token'),
    lp_access_secret                    => hiera('gerrit_lp_access_secret'),
    lp_consumer_key                     => hiera('gerrit_lp_consumer_key'),
    swift_username                      => hiera('swift_store_user', 'username'),
    swift_password                      => hiera('swift_store_key'),
    storyboard_password                 => hiera('gerrit_storyboard_token'),
  }
}

# Node-OS: trusty
node 'review-dev.openstack.org' {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80, 443, 29418],
    sysadmins                 => hiera('sysadmins', []),
    afs                       => true,
  }

  class { 'openstack_project::review_dev':
    project_config_repo                 => 'https://git.openstack.org/openstack-infra/project-config',
    github_oauth_token                  => hiera('gerrit_dev_github_token'),
    github_project_username             => hiera('github_dev_project_username', 'username'),
    github_project_password             => hiera('github_dev_project_password'),
    mysql_host                          => hiera('gerrit_dev_mysql_host', 'localhost'),
    mysql_password                      => hiera('gerrit_dev_mysql_password'),
    email_private_key                   => hiera('gerrit_dev_email_private_key'),
    ssh_dsa_key_contents                => hiera('gerrit_dev_ssh_dsa_key_contents'),
    ssh_dsa_pubkey_contents             => hiera('gerrit_dev_ssh_dsa_pubkey_contents'),
    ssh_rsa_key_contents                => hiera('gerrit_dev_ssh_rsa_key_contents'),
    ssh_rsa_pubkey_contents             => hiera('gerrit_dev_ssh_rsa_pubkey_contents'),
    ssh_project_rsa_key_contents        => hiera('gerrit_dev_project_ssh_rsa_key_contents'),
    ssh_project_rsa_pubkey_contents     => hiera('gerrit_dev_project_ssh_rsa_pubkey_contents'),
    ssh_replication_rsa_key_contents    => hiera('gerrit_dev_replication_ssh_rsa_key_contents'),
    ssh_replication_rsa_pubkey_contents => hiera('gerrit_dev_replication_ssh_rsa_pubkey_contents'),
    lp_access_token                     => hiera('gerrit_dev_lp_access_token'),
    lp_access_secret                    => hiera('gerrit_dev_lp_access_secret'),
    lp_consumer_key                     => hiera('gerrit_dev_lp_consumer_key'),
    storyboard_password                 => hiera('gerrit_dev_storyboard_token'),
    storyboard_ssl_cert                 => hiera('gerrit_dev_storyboard_ssl_crt'),
  }
}

# Node-OS: trusty
# Node-OS: xenial
node /^grafana\d*\.openstack\.org$/ {
  $group = "grafana"
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80],
    sysadmins                 => hiera('sysadmins', []),
  }
  class { 'openstack_project::grafana':
    admin_password      => hiera('grafana_admin_password'),
    admin_user          => hiera('grafana_admin_user', 'username'),
    mysql_host          => hiera('grafana_mysql_host', 'localhost'),
    mysql_name          => hiera('grafana_mysql_name'),
    mysql_password      => hiera('grafana_mysql_password'),
    mysql_user          => hiera('grafana_mysql_user', 'username'),
    project_config_repo => 'https://git.openstack.org/openstack-infra/project-config',
    secret_key          => hiera('grafana_secret_key'),
  }
}

# Node-OS: trusty
# Node-OS: xenial
node /^health\d*\.openstack\.org$/ {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80, 443],
    sysadmins                 => hiera('sysadmins', []),
  }
  class { 'openstack_project::openstack_health_api':
    subunit2sql_db_host => hiera('subunit2sql_db_host', 'localhost'),
  }
}

# Node-OS: trusty
# Node-OS: xenial
node /^stackalytics\d*\.openstack\.org$/ {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80],
    sysadmins                 => hiera('sysadmins', []),
  }

  class { 'openstack_project::stackalytics':
    gerrit_ssh_user              => hiera('stackalytics_gerrit_ssh_user'),
    stackalytics_ssh_private_key => hiera('stackalytics_ssh_private_key_contents'),
  }
}

# Node-OS: xenial
node /^cacti\d+\.openstack\.org$/ {
  $group = "cacti"
  include openstack_project::ssl_cert_check
  class { 'openstack_project::cacti':
    sysadmins   => hiera('sysadmins', []),
    cacti_hosts => hiera_array('cacti_hosts'),
    vhost_name  => 'cacti.openstack.org',
  }
}

# Node-OS: trusty
node 'puppetmaster.openstack.org' {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [8140],
    sysadmins                 => hiera('sysadmins', []),
    pin_puppet                => '3.6.',
  }
  class { 'openstack_project::puppetmaster':
    root_rsa_key                               => hiera('puppetmaster_root_rsa_key'),
    puppetmaster_clouds                        => hiera('puppetmaster_clouds'),
    enable_mqtt                                => true,
    mqtt_password                              => hiera('mqtt_service_user_password'),
    mqtt_ca_cert_contents                      => hiera('mosquitto_tls_ca_file'),
  }
  file { '/etc/openstack/infracloud_vanilla_cacert.pem':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => hiera('infracloud_vanilla_ssl_cert_file_contents'),
    require => Class['::openstack_project::puppetmaster'],
  }
  file { '/etc/openstack/infracloud_chocolate_cacert.pem':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => hiera('infracloud_chocolate_ssl_cert_file_contents'),
    require => Class['::openstack_project::puppetmaster'],
  }
}

# Node-OS: trusty
# Node-OS: xenial
node /^graphite\d*\.openstack\.org$/ {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80, 443],
    iptables_allowed_hosts    => [
      {protocol => 'udp', port => '8125', hostname => 'git.openstack.org'},
      {protocol => 'udp', port => '8125', hostname => 'firehose01.openstack.org'},
      {protocol => 'udp', port => '8125', hostname => 'logstash.openstack.org'},
      {protocol => 'udp', port => '8125', hostname => 'nodepool.openstack.org'},
      {protocol => 'udp', port => '8125', hostname => 'nl01.openstack.org'},
      {protocol => 'udp', port => '8125', hostname => 'nl02.openstack.org'},
      {protocol => 'udp', port => '8125', hostname => 'zuul.openstack.org'},
      {protocol => 'udp', port => '8125', hostname => 'zuulv3.openstack.org'},
      {protocol => 'udp', port => '8125', hostname => 'zm01.openstack.org'},
      {protocol => 'udp', port => '8125', hostname => 'zm02.openstack.org'},
      {protocol => 'udp', port => '8125', hostname => 'zm03.openstack.org'},
      {protocol => 'udp', port => '8125', hostname => 'zm04.openstack.org'},
      {protocol => 'udp', port => '8125', hostname => 'zm05.openstack.org'},
      {protocol => 'udp', port => '8125', hostname => 'zm06.openstack.org'},
      {protocol => 'udp', port => '8125', hostname => 'zm07.openstack.org'},
      {protocol => 'udp', port => '8125', hostname => 'zm08.openstack.org'},
      {protocol => 'udp', port => '8125', hostname => 'ze01.openstack.org'},
      {protocol => 'udp', port => '8125', hostname => 'ze02.openstack.org'},
      {protocol => 'udp', port => '8125', hostname => 'ze03.openstack.org'},
      {protocol => 'udp', port => '8125', hostname => 'ze04.openstack.org'},
      {protocol => 'udp', port => '8125', hostname => 'ze05.openstack.org'},
      {protocol => 'udp', port => '8125', hostname => 'ze06.openstack.org'},
      {protocol => 'udp', port => '8125', hostname => 'ze07.openstack.org'},
      {protocol => 'udp', port => '8125', hostname => 'ze08.openstack.org'},
      {protocol => 'udp', port => '8125', hostname => 'ze09.openstack.org'},
      {protocol => 'udp', port => '8125', hostname => 'ze10.openstack.org'},
    ],
    sysadmins                 => hiera('sysadmins', [])
  }

  class { '::graphite':
    graphite_admin_user     => hiera('graphite_admin_user', 'username'),
    graphite_admin_email    => hiera('graphite_admin_email', 'email@example.com'),
    graphite_admin_password => hiera('graphite_admin_password'),
  }
}

# Node-OS: trusty
# Node-OS: xenial
node /^groups\d*\.openstack\.org$/ {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [22, 80, 443],
    sysadmins                 => hiera('sysadmins', []),
  }
  class { 'openstack_project::groups':
    site_admin_password          => hiera('groups_site_admin_password'),
    site_mysql_host              => hiera('groups_site_mysql_host', 'localhost'),
    site_mysql_password          => hiera('groups_site_mysql_password'),
    conf_cron_key                => hiera('groups_conf_cron_key'),
    site_ssl_cert_file_contents  => hiera('groups_site_ssl_cert_file_contents', undef),
    site_ssl_key_file_contents   => hiera('groups_site_ssl_key_file_contents', undef),
    site_ssl_chain_file_contents => hiera('groups_site_ssl_chain_file_contents', undef),
  }
}

# Node-OS: trusty
# Node-OS: xenial
node /^groups-dev\d*\.openstack\.org$/ {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [22, 80, 443],
    sysadmins                 => hiera('sysadmins', []),
  }
  class { 'openstack_project::groups_dev':
    site_admin_password          => hiera('groups_dev_site_admin_password'),
    site_mysql_host              => hiera('groups_dev_site_mysql_host', 'localhost'),
    site_mysql_password          => hiera('groups_dev_site_mysql_password'),
    conf_cron_key                => hiera('groups_dev_conf_cron_key'),
    site_ssl_cert_file_contents  => hiera('groups_dev_site_ssl_cert_file_contents', undef),
    site_ssl_key_file_contents   => hiera('groups_dev_site_ssl_key_file_contents', undef),
    site_ssl_cert_file           => '/etc/ssl/certs/groups-dev.openstack.org.pem',
    site_ssl_key_file            => '/etc/ssl/private/groups-dev.openstack.org.key',
  }
}

# Node-OS: trusty
# Node-OS: xenial
node /^lists\d*\.openstack\.org$/ {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [25, 80, 465],
    manage_exim => false,
    purge_apt_sources => false,
  }

  class { 'openstack_project::lists':
    listadmins   => hiera('listadmins', []),
    listpassword => hiera('listpassword'),
  }
}

# Node-OS: trusty
# Node-OS: xenial
node /^lists\d*\.katacontainers\.io$/ {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [25, 80, 465],
    manage_exim => false,
    purge_apt_sources => false,
  }

  class { 'openstack_project::kata_lists':
    listadmins   => hiera('listadmins', []),
    listpassword => hiera('listpassword'),
  }
}

# Node-OS: trusty
# Node-OS: xenial
node /^paste\d*\.openstack\.org$/ {
  $group = "paste"

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80],
    sysadmins                 => hiera('sysadmins', []),
  }
  class { 'openstack_project::paste':
    db_password         => hiera('paste_db_password'),
    db_host             => hiera('paste_db_host'),
    vhost_name          => 'paste.openstack.org',
  }
}

# Node-OS: trusty
# Node-OS: xenial
node /planet\d*\.openstack\.org$/ {
  class { 'openstack_project::planet':
    sysadmins => hiera('sysadmins', []),
  }
}

# Node-OS: trusty
# Node-OS: xenial
node /^eavesdrop\d*\.openstack\.org$/ {
  $group = "eavesdrop"
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80],
    sysadmins                 => hiera('sysadmins', []),
  }

  class { 'openstack_project::eavesdrop':
    project_config_repo     => 'https://git.openstack.org/openstack-infra/project-config',
    nickpass                => hiera('openstack_meetbot_password'),
    statusbot_nick          => hiera('statusbot_nick', 'username'),
    statusbot_password      => hiera('statusbot_nick_password'),
    statusbot_server        => 'chat.freenode.net',
    statusbot_channels      => hiera_array('statusbot_channels', ['openstack_infra']),
    statusbot_auth_nicks    => hiera_array('statusbot_auth_nicks'),
    statusbot_wiki_user     => hiera('statusbot_wiki_username', 'username'),
    statusbot_wiki_password => hiera('statusbot_wiki_password'),
    statusbot_wiki_url      => 'https://wiki.openstack.org/w/api.php',
    # https://wiki.openstack.org/wiki/Infrastructure_Status
    statusbot_wiki_pageid   => '1781',
    # https://wiki.openstack.org/wiki/Successes
    statusbot_wiki_successpageid => '7717',
    # https://wiki.openstack.org/wiki/Thanks
    statusbot_wiki_thankspageid => '37700',
    statusbot_irclogs_url   => 'http://eavesdrop.openstack.org/irclogs/%(chan)s/%(chan)s.%(date)s.log.html',
    statusbot_twitter                 => true,
    statusbot_twitter_key             => hiera('statusbot_twitter_key'),
    statusbot_twitter_secret          => hiera('statusbot_twitter_secret'),
    statusbot_twitter_token_key       => hiera('statusbot_twitter_token_key'),
    statusbot_twitter_token_secret    => hiera('statusbot_twitter_token_secret'),
    accessbot_nick          => hiera('accessbot_nick', 'username'),
    accessbot_password      => hiera('accessbot_nick_password'),
    meetbot_channels        => hiera('meetbot_channels', ['openstack-infra']),
    ptgbot_nick             => hiera('ptgbot_nick', 'username'),
    ptgbot_password         => hiera('ptgbot_password'),
  }
}

# Node-OS: trusty
# Node-OS: xenial
node /^ethercalc\d+\.openstack\.org$/ {
  $group = "ethercalc"
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [22, 80, 443],
    sysadmins                 => hiera('sysadmins', []),
  }

  class { 'openstack_project::ethercalc':
    vhost_name              => 'ethercalc.openstack.org',
    ssl_cert_file_contents  => hiera('ssl_cert_file_contents'),
    ssl_key_file_contents   => hiera('ssl_key_file_contents'),
    ssl_chain_file_contents => hiera('ssl_chain_file_contents'),
  }
}

# Node-OS: trusty
# Node-OS: xenial
node /^etherpad\d*\.openstack\.org$/ {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [22, 80, 443],
    sysadmins                 => hiera('sysadmins', []),
  }

  class { 'openstack_project::etherpad':
    ssl_cert_file_contents  => hiera('etherpad_ssl_cert_file_contents'),
    ssl_key_file_contents   => hiera('etherpad_ssl_key_file_contents'),
    ssl_chain_file_contents => hiera('etherpad_ssl_chain_file_contents'),
    mysql_host              => hiera('etherpad_db_host', 'localhost'),
    mysql_user              => hiera('etherpad_db_user', 'username'),
    mysql_password          => hiera('etherpad_db_password'),
  }
}

# Node-OS: trusty
# Node-OS: xenial
node /^etherpad-dev\d*\.openstack\.org$/ {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [22, 80, 443],
    sysadmins                 => hiera('sysadmins', []),
  }

  class { 'openstack_project::etherpad_dev':
    mysql_host          => hiera('etherpad-dev_db_host', 'localhost'),
    mysql_user          => hiera('etherpad-dev_db_user', 'username'),
    mysql_password      => hiera('etherpad-dev_db_password'),
  }
}

# Node-OS: trusty
node /^wiki\d+\.openstack\.org$/ {
  $group = "wiki"
  class { 'openstack_project::wiki':
    sysadmins                 => hiera('sysadmins', []),
    bup_user                  => 'bup-wiki',
    serveradmin               => hiera('infra_apache_serveradmin'),
    site_hostname             => 'wiki.openstack.org',
    ssl_cert_file_contents    => hiera('ssl_cert_file_contents'),
    ssl_key_file_contents     => hiera('ssl_key_file_contents'),
    ssl_chain_file_contents   => hiera('ssl_chain_file_contents'),
    wg_dbserver               => hiera('wg_dbserver'),
    wg_dbname                 => 'openstack_wiki',
    wg_dbuser                 => 'wikiuser',
    wg_dbpassword             => hiera('wg_dbpassword'),
    wg_secretkey              => hiera('wg_secretkey'),
    wg_upgradekey             => hiera('wg_upgradekey'),
    wg_recaptchasitekey       => hiera('wg_recaptchasitekey'),
    wg_recaptchasecretkey     => hiera('wg_recaptchasecretkey'),
    wg_googleanalyticsaccount => hiera('wg_googleanalyticsaccount'),
  }
}

# Node-OS: trusty
node /^wiki-dev\d+\.openstack\.org$/ {
  $group = "wiki-dev"
  class { 'openstack_project::wiki':
    sysadmins             => hiera('sysadmins', []),
    serveradmin           => hiera('infra_apache_serveradmin'),
    site_hostname         => 'wiki-dev.openstack.org',
    wg_dbserver           => hiera('wg_dbserver'),
    wg_dbname             => 'openstack_wiki',
    wg_dbuser             => 'wikiuser',
    wg_dbpassword         => hiera('wg_dbpassword'),
    wg_secretkey          => hiera('wg_secretkey'),
    wg_upgradekey         => hiera('wg_upgradekey'),
    wg_recaptchasitekey   => hiera('wg_recaptchasitekey'),
    wg_recaptchasecretkey => hiera('wg_recaptchasecretkey'),
    disallow_robots       => true,
  }
}

# Node-OS: trusty
# Node-OS: xenial
node /^logstash\d*\.openstack\.org$/ {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [22, 80, 3306],
    iptables_allowed_hosts    => hiera_array('logstash_iptables_rule_data'),
    sysadmins                 => hiera('sysadmins', []),
  }

  class { 'openstack_project::logstash':
    discover_nodes      => [
      'elasticsearch03.openstack.org:9200',
      'elasticsearch04.openstack.org:9200',
      'elasticsearch05.openstack.org:9200',
      'elasticsearch06.openstack.org:9200',
      'elasticsearch07.openstack.org:9200',
      'elasticsearch02.openstack.org:9200',
    ],
    subunit2sql_db_host => hiera('subunit2sql_db_host', ''),
    subunit2sql_db_pass => hiera('subunit2sql_db_password', ''),
  }
}

# Node-OS: trusty
# Node-OS: xenial
node /^logstash-worker\d+\.openstack\.org$/ {
  $group = 'logstash-worker'

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [22],
    sysadmins                 => hiera('sysadmins', []),
  }

  class { 'openstack_project::logstash_worker':
    discover_node         => 'elasticsearch03.openstack.org',
    enable_mqtt           => false,
    mqtt_password         => hiera('mqtt_service_user_password'),
    mqtt_ca_cert_contents => hiera('mosquitto_tls_ca_file'),
  }
}

# Node-OS: trusty
# Node-OS: xenial
node /^subunit-worker\d+\.openstack\.org$/ {
  $group = "subunit-worker"
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [22],
    sysadmins                 => hiera('sysadmins', []),
  }
  class { 'openstack_project::subunit_worker':
    subunit2sql_db_host   => hiera('subunit2sql_db_host', ''),
    subunit2sql_db_pass   => hiera('subunit2sql_db_password', ''),
    mqtt_pass             => hiera('mqtt_service_user_password'),
    mqtt_ca_cert_contents => hiera('mosquitto_tls_ca_file'),
  }
}


# Node-OS: xenial
node /^subunit-check-worker\d+\.openstack\.org$/ {
  $group = 'subunit-check-worker'
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [22],
    sysadmins                 => hiera('sysadmins', []),
  }
  class { 'openstack_project::subunit_worker':
    subunit2sql_db_host   => 'subunit2sql-check-db.openstack.org',
    subunit2sql_db_pass   => hiera('subunit2sql_check_db_password', ''),
    mqtt_pass             => hiera('mqtt_service_user_password'),
    mqtt_ca_cert_contents => hiera('mosquitto_tls_ca_file'),
    check_queue           => true,
  }
}

# Node-OS: xenial
node 'subunit2sql-check-db.openstack.org' {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [22, 80, 3306],
    iptables_rules6           => $logstash_iptables_rule,
    iptables_rules4           => $logstash_iptables_rule,
    sysadmins                 => hiera('sysadmins', []),
  }

  class { 'openstack_project::subunit_db_server':
    subunit2sql_db_host => 'subunit2sql-check-db.openstack.org',
    subunit2sql_db_pass => hiera('subunit2sql_check_db_password', ''),
    root_mysql_pass     => hiera('subunit2sql_check_db_root_password', ''),
    expire_age          => '30',
  }
}

# Node-OS: trusty
# Node-OS: xenial
node /^elasticsearch0[1-7]\.openstack\.org$/ {
  $group = "elasticsearch"
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [22],
    iptables_allowed_hosts    => hiera_array('elasticsearch_iptables_rule_data'),
    sysadmins                 => hiera('sysadmins', []),
  }
  class { 'openstack_project::elasticsearch_node':
    discover_nodes => $elasticsearch_nodes,
  }
}

# Node-OS: xenial
node /^firehose\d+\.openstack\.org$/ {
  class { 'openstack_project::server':
    # NOTE(mtreinish) Port 80 and 8080 are disabled because websocket
    # connections seem to crash mosquitto. Once this is fixed we should add
    # them back
    iptables_public_tcp_ports => [22, 25, 1883, 8883],
    sysadmins                 => hiera('sysadmins', []),
    manage_exim               => false,
  }
  class { 'openstack_project::firehose':
    sysadmins           => hiera('sysadmins', []),
    gerrit_ssh_host_key => hiera('gerrit_ssh_rsa_pubkey_contents'),
    gerrit_public_key   => hiera('germqtt_gerrit_ssh_public_key'),
    gerrit_private_key  => hiera('germqtt_gerrit_ssh_private_key'),
    mqtt_password       => hiera('mqtt_service_user_password'),
    ca_file             => hiera('mosquitto_tls_ca_file'),
    cert_file           => hiera('mosquitto_tls_server_cert_file'),
    key_file            => hiera('mosquitto_tls_server_key_file'),
    imap_hostname       => hiera('lpmqtt_imap_server'),
    imap_username       => hiera('lpmqtt_imap_username'),
    imap_password       => hiera('lpmqtt_imap_password'),
    statsd_host         => 'graphite.openstack.org',
  }
}

# CentOS machines to load balance git access.
# Node-OS: centos7
node /^git(-fe\d+)?\.openstack\.org$/ {
  $group = "git-loadbalancer"
  class { 'openstack_project::git':
    sysadmins               => hiera('sysadmins', []),
    balancer_member_names   => [
      'git01.openstack.org',
      'git02.openstack.org',
      'git03.openstack.org',
      'git04.openstack.org',
      'git05.openstack.org',
      'git06.openstack.org',
      'git07.openstack.org',
      'git08.openstack.org',
    ],
    balancer_member_ips     => [
      '104.130.243.237',
      '104.130.243.109',
      '67.192.247.197',
      '67.192.247.180',
      '23.253.69.135',
      '104.239.132.223',
      '23.253.94.84',
      '104.239.146.131',
    ],
  }
}

# CentOS machines to run cgit and git daemon. Will be
# load balanced by git.openstack.org.
# Node-OS: centos7
node /^git\d+\.openstack\.org$/ {
  $group = "git-server"
  include openstack_project
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [4443, 8080, 29418],
    sysadmins                 => hiera('sysadmins', []),
  }

  class { 'openstack_project::git_backend':
    project_config_repo     => 'https://git.openstack.org/openstack-infra/project-config',
    vhost_name              => 'git.openstack.org',
    git_gerrit_ssh_key      => hiera('gerrit_replication_ssh_rsa_pubkey_contents'),
    ssl_cert_file_contents  => hiera('git_ssl_cert_file_contents'),
    ssl_key_file_contents   => hiera('git_ssl_key_file_contents'),
    ssl_chain_file_contents => hiera('git_ssl_chain_file_contents'),
    behind_proxy            => true,
    selinux_mode            => 'enforcing'
  }
}

# A machine to drive AFS mirror updates.
# Node-OS: trusty
# Node-OS: xenial
node /^mirror-update\d*\.openstack\.org$/ {
  $group = "afsadmin"

  class { 'openstack_project::mirror_update':
    bandersnatch_keytab => hiera('bandersnatch_keytab'),
    admin_keytab        => hiera('afsadmin_keytab'),
    fedora_keytab       => hiera('fedora_keytab'),
    opensuse_keytab     => hiera('opensuse_keytab'),
    reprepro_keytab     => hiera('reprepro_keytab'),
    gem_keytab          => hiera('gem_keytab'),
    centos_keytab       => hiera('centos_keytab'),
    epel_keytab         => hiera('epel_keytab'),
    sysadmins           => hiera('sysadmins', []),
  }
}

# Machines in each region to serve AFS mirrors.
# Node-OS: xenial
node /^mirror\d*\..*\.openstack\.org$/ {
  $group = "mirror"

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [22, 80, 8080, 8081],
    sysadmins                 => hiera('sysadmins', []),
    afs                       => true,
    afs_cache_size            => 50000000,  # 50GB
  }

  class { 'openstack_project::mirror':
    vhost_name => $::fqdn,
    require    => Class['Openstack_project::Server'],
  }
}

# Serve static AFS content for docs and other sites.
# Node-OS: trusty
# Node-OS: xenial
node /^files\d*\.openstack\.org$/ {
  $group = "files"
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80, 443],
    sysadmins                 => hiera('sysadmins', []),
    afs                       => true,
    afs_cache_size            => 10000000,  # 10GB
  }

  class { 'openstack_project::files':
    vhost_name                    => 'files.openstack.org',
    developer_cert_file_contents  => hiera('developer_cert_file_contents'),
    developer_key_file_contents   => hiera('developer_key_file_contents'),
    developer_chain_file_contents => hiera('developer_chain_file_contents'),
    docs_cert_file_contents       => hiera('docs_cert_file_contents'),
    docs_key_file_contents        => hiera('docs_key_file_contents'),
    docs_chain_file_contents      => hiera('docs_chain_file_contents'),
    require                       => Class['Openstack_project::Server'],
  }
}

# Node-OS: trusty
# Node-OS: xenial
node /^refstack\d*\.openstack\.org$/ {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80, 443],
    sysadmins                 => hiera('sysadmins', []),
  }
  class { 'refstack':
    mysql_host          => hiera('refstack_mysql_host', 'localhost'),
    mysql_database      => hiera('refstack_mysql_db_name', 'refstack'),
    mysql_user          => hiera('refstack_mysql_user', 'refstack'),
    mysql_user_password => hiera('refstack_mysql_password'),
    ssl_cert_content    => hiera('refstack_ssl_cert_file_contents'),
    ssl_key_content     => hiera('refstack_ssl_key_file_contents'),
    ssl_ca_content      => hiera('refstack_ssl_chain_file_contents'),
    protocol            => 'https',
  }
  mysql_backup::backup_remote { 'refstack':
    database_host     => hiera('refstack_mysql_host', 'localhost'),
    database_user     => hiera('refstack_mysql_user', 'refstack'),
    database_password => hiera('refstack_mysql_password'),
    require           => Class['::refstack'],
  }
}

# A machine to run Storyboard
# Node-OS: trusty
# Node-OS: xenial
node /^storyboard\d*\.openstack\.org$/ {
  class { 'openstack_project::storyboard':
    project_config_repo     => 'https://git.openstack.org/openstack-infra/project-config',
    sysadmins               => hiera('sysadmins', []),
    mysql_host              => hiera('storyboard_db_host', 'localhost'),
    mysql_user              => hiera('storyboard_db_user', 'username'),
    mysql_password          => hiera('storyboard_db_password'),
    rabbitmq_user           => hiera('storyboard_rabbit_user', 'username'),
    rabbitmq_password       => hiera('storyboard_rabbit_password'),
    ssl_cert                => '/etc/ssl/certs/storyboard.openstack.org.pem',
    ssl_cert_file_contents  => hiera('storyboard_ssl_cert_file_contents'),
    ssl_key                 => '/etc/ssl/private/storyboard.openstack.org.key',
    ssl_key_file_contents   => hiera('storyboard_ssl_key_file_contents'),
    ssl_chain_file_contents => hiera('storyboard_ssl_chain_file_contents'),
    hostname                => $::fqdn,
    valid_oauth_clients     => [
      $::fqdn,
      'logs.openstack.org',
    ],
    cors_allowed_origins     => [
      "https://${::fqdn}",
      'http://logs.openstack.org',
    ],
    sender_email_address => 'storyboard@storyboard.openstack.org',
  }
}

# A machine to run Storyboard devel
# Node-OS: trusty
# Node-OS: xenial
node /^storyboard-dev\d*\.openstack\.org$/ {
  class { 'openstack_project::storyboard::dev':
    project_config_repo     => 'https://git.openstack.org/openstack-infra/project-config',
    sysadmins               => hiera('sysadmins', []),
    mysql_host              => hiera('storyboard_db_host', 'localhost'),
    mysql_user              => hiera('storyboard_db_user', 'username'),
    mysql_password          => hiera('storyboard_db_password'),
    rabbitmq_user           => hiera('storyboard_rabbit_user', 'username'),
    rabbitmq_password       => hiera('storyboard_rabbit_password'),
    hostname                => $::fqdn,
    valid_oauth_clients     => [
      $::fqdn,
      'logs.openstack.org',
    ],
    cors_allowed_origins     => [
      "https://${::fqdn}",
      'http://logs.openstack.org',
    ],
    sender_email_address => 'storyboard-dev@storyboard-dev.openstack.org',
  }

}

# A machine to serve static content.
# Node-OS: trusty
# Node-OS: xenial
node /^static\d*\.openstack\.org$/ {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [22, 80, 443],
    sysadmins                 => hiera('sysadmins', []),
  }
  class { 'openstack_project::static':
    project_config_repo     => 'https://git.openstack.org/openstack-infra/project-config',
    swift_authurl           => 'https://identity.api.rackspacecloud.com/v2.0/',
    swift_user              => 'infra-files-ro',
    swift_key               => hiera('infra_files_ro_password'),
    swift_tenant_name       => hiera('infra_files_tenant_name', 'tenantname'),
    swift_region_name       => 'DFW',
    swift_default_container => 'infra-files',
    ssl_cert_file_contents  => hiera('static_ssl_cert_file_contents'),
    ssl_key_file_contents   => hiera('static_ssl_key_file_contents'),
    ssl_chain_file_contents => hiera('static_ssl_chain_file_contents'),
  }
}

# Node-OS: xenial
node /^zk\d+\.openstack\.org$/ {
  $zk_receivers = [
    'nb03.openstack.org',
    'nb04.openstack.org',
    'nl01.openstack.org',
    'nl02.openstack.org',
    'zuulv3.openstack.org',
  ]

  $zk_cluster_members = [
    'zk01.openstack.org',
    'zk02.openstack.org',
    'zk03.openstack.org',
  ]

  $zk_receiver_rule = regsubst($zk_receivers,
                               '^(.*)$', '-m state --state NEW -m tcp -p tcp --dport 2181 -s \1 -j ACCEPT')
  $zk_election_rule = regsubst($zk_cluster_members,
                               '^(.*)$', '-m state --state NEW -m tcp -p tcp --dport 2888 -s \1 -j ACCEPT')
  $zk_leader_rule = regsubst($zk_cluster_members,
                             '^(.*)$', '-m state --state NEW -m tcp -p tcp --dport 3888 -s \1 -j ACCEPT')
  $iptables_rule = flatten([$zk_receiver_rule, $zk_election_rule, $zk_leader_rule])
  class { 'openstack_project::server':
    iptables_rules6           => $iptables_rule,
    iptables_rules4           => $iptables_rule,
    sysadmins                 => hiera('sysadmins', []),
  }

  class { '::zookeeper':
    # ID needs to be numeric, so we use regex to extra numbers from fqdn.
    id             => regsubst($::fqdn, '^zk(\d+)\.openstack\.org$', '\1'),
    # The frequency in hours to look for and purge old snapshots,
    # defaults to 0 (disabled). The number of retained snapshots can
    # be separately controlled through snap_retain_count and
    # defaults to the minimum value of 3. This will quickly fill the
    # disk in production if not enabled. Works on ZK >=3.4.
    purge_interval => 6,
    servers        => $zk_cluster_members,
  }
}

# A machine to serve various project status updates.
# Node-OS: trusty
# Node-OS: xenial
node /^status\d*\.openstack\.org$/ {
  $group = 'status'

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [22, 80, 443],
    sysadmins                 => hiera('sysadmins', []),
  }

  class { 'openstack_project::status':
    gerrit_host                   => 'review.openstack.org',
    gerrit_ssh_host_key           => hiera('gerrit_ssh_rsa_pubkey_contents'),
    reviewday_ssh_public_key      => hiera('reviewday_rsa_pubkey_contents'),
    reviewday_ssh_private_key     => hiera('reviewday_rsa_key_contents'),
    recheck_ssh_public_key        => hiera('elastic-recheck_gerrit_ssh_public_key'),
    recheck_ssh_private_key       => hiera('elastic-recheck_gerrit_ssh_private_key'),
    recheck_bot_nick              => 'openstackrecheck',
    recheck_bot_passwd            => hiera('elastic-recheck_ircbot_password'),
  }
}

# Node-OS: xenial
node /^ns\d+\.openstack\.org$/ {
  $group = 'ns'

  class { 'openstack_project::server':
    sysadmins                 => hiera('sysadmins', []),
    iptables_public_udp_ports => [53],
  }

  class { '::nsd':
    zones => {
      'master_zones' => {
        'zones' => ['zuul-ci.org'],
      },
    }
  }
}

# Node-OS: trusty
node 'nodepool.openstack.org' {
  $group = 'nodepool'
  # TODO(pabelanger): Move all of this back into nodepool manifest, it has
  # grown too big.
  $rackspace_username  = hiera('nodepool_rackspace_username', 'username')
  $rackspace_password  = hiera('nodepool_rackspace_password')
  $rackspace_project   = hiera('nodepool_rackspace_project', 'project')
  $hpcloud_username    = hiera('nodepool_hpcloud_username', 'username')
  $hpcloud_password    = hiera('nodepool_hpcloud_password')
  $hpcloud_project     = hiera('nodepool_hpcloud_project', 'project')
  $internap_username   = hiera('nodepool_internap_username', 'username')
  $internap_password   = hiera('nodepool_internap_password')
  $internap_project    = hiera('nodepool_internap_project', 'project')
  $ovh_username        = hiera('nodepool_ovh_username', 'username')
  $ovh_password        = hiera('nodepool_ovh_password')
  $ovh_project         = hiera('nodepool_ovh_project', 'project')
  $tripleo_username    = hiera('nodepool_tripleo_username', 'username')
  $tripleo_password    = hiera('nodepool_tripleo_password')
  $tripleo_project     = hiera('nodepool_tripleo_project', 'project')
  $infracloud_vanilla_username    = hiera('nodepool_infracloud_vanilla_username', 'username')
  $infracloud_vanilla_password    = hiera('nodepool_infracloud_vanilla_password')
  $infracloud_vanilla_project     = hiera('nodepool_infracloud_vanilla_project', 'project')
  $infracloud_chocolate_username  = hiera('nodepool_infracloud_chocolate_username', 'username')
  $infracloud_chocolate_password  = hiera('nodepool_infracloud_chocolate_password')
  $infracloud_chocolate_project   = hiera('nodepool_infracloud_chocolate_project', 'project')
  $vexxhost_username   = hiera('nodepool_vexxhost_username', 'username')
  $vexxhost_password   = hiera('nodepool_vexxhost_password')
  $vexxhost_project    = hiera('nodepool_vexxhost_project', 'project')
  $citycloud_username = hiera('nodepool_citycloud_username', 'username')
  $citycloud_password = hiera('nodepool_citycloud_password')
  $clouds_yaml = template("openstack_project/nodepool/clouds.yaml.erb")

  $zk_receivers = [
    'nb01.openstack.org',
    'nb02.openstack.org',
    'nb03.openstack.org',
    'nb04.openstack.org',
    'nl01.openstack.org',
    'nl02.openstack.org',
    'zuulv3-dev.openstack.org',
    'zuulv3.openstack.org',
  ]
  $zk_iptables_rule = regsubst($zk_receivers,
                               '^(.*)$', '-m state --state NEW -m tcp -p tcp --dport 2181 -s \1 -j ACCEPT')
  $iptables_rule = flatten([$zk_iptables_rule])
  class { 'openstack_project::server':
    iptables_rules6           => $iptables_rule,
    iptables_rules4           => $iptables_rule,
    sysadmins                 => hiera('sysadmins', []),
    iptables_public_tcp_ports => [80],
  }

  class { '::zookeeper':
    # The frequency in hours to look for and purge old snapshots,
    # defaults to 0 (disabled). The number of retained snapshots can
    # be separately controlled through snap_retain_count and
    # defaults to the minimum value of 3. This will quickly fill the
    # disk in production if not enabled. Works on ZK >=3.4.
    purge_interval => 6,
  }

  include openstack_project

  class { '::openstackci::nodepool':
    vhost_name                    => 'nodepool.openstack.org',
    project_config_repo           => 'https://git.openstack.org/openstack-infra/project-config',
    mysql_password                => hiera('nodepool_mysql_password'),
    mysql_root_password           => hiera('nodepool_mysql_root_password'),
    nodepool_ssh_public_key       => hiera('zuul_worker_ssh_public_key_contents'),
    # TODO(pabelanger): Switch out private key with zuul_worker once we are
    # ready.
    nodepool_ssh_private_key      => hiera('jenkins_ssh_private_key_contents'),
    oscc_file_contents            => $clouds_yaml,
    image_log_document_root       => '/var/log/nodepool/image',
    statsd_host                   => 'graphite.openstack.org',
    logging_conf_template         => 'openstack_project/nodepool/nodepool.logging.conf.erb',
    builder_logging_conf_template => 'openstack_project/nodepool/nodepool-builder.logging.conf.erb',
    upload_workers                => '16',
    jenkins_masters               => [],
    split_daemon                  => true,
  }
  file { '/home/nodepool/.config/openstack/infracloud_vanilla_cacert.pem':
    ensure  => present,
    owner   => 'nodepool',
    group   => 'nodepool',
    mode    => '0600',
    content => hiera('infracloud_vanilla_ssl_cert_file_contents'),
    require => Class['::openstackci::nodepool'],
  }
  file { '/home/nodepool/.config/openstack/infracloud_chocolate_cacert.pem':
    ensure  => present,
    owner   => 'nodepool',
    group   => 'nodepool',
    mode    => '0600',
    content => hiera('infracloud_chocolate_ssl_cert_file_contents'),
    require => Class['::openstackci::nodepool'],
  }

  cron { 'mirror_gitgc':
    user        => 'nodepool',
    hour        => '20',
    minute      => '0',
    command     => 'find /opt/dib_cache/source-repositories/ -maxdepth 1 -type d -name "*.git" -exec git --git-dir="{}" gc \; >/dev/null',
    environment => 'PATH=/usr/bin:/bin:/usr/sbin:/sbin',
    require     => Class['::openstackci::nodepool'],
  }
}

# Node-OS: trusty
# Node-OS: xenial
node /^nl\d+\.openstack\.org$/ {
  $group = 'nodepool'
  # TODO(pabelanger): Move all of this back into nodepool manifest, it has
  # grown too big.
  $rackspace_username             = hiera('nodepool_rackspace_username', 'username')
  $rackspace_password             = hiera('nodepool_rackspace_password')
  $rackspace_project              = hiera('nodepool_rackspace_project', 'project')
  $hpcloud_username               = hiera('nodepool_hpcloud_username', 'username')
  $hpcloud_password               = hiera('nodepool_hpcloud_password')
  $hpcloud_project                = hiera('nodepool_hpcloud_project', 'project')
  $internap_username              = hiera('nodepool_internap_username', 'username')
  $internap_password              = hiera('nodepool_internap_password')
  $internap_project               = hiera('nodepool_internap_project', 'project')
  $ovh_username                   = hiera('nodepool_ovh_username', 'username')
  $ovh_password                   = hiera('nodepool_ovh_password')
  $ovh_project                    = hiera('nodepool_ovh_project', 'project')
  $tripleo_username               = hiera('nodepool_tripleo_username', 'username')
  $tripleo_password               = hiera('nodepool_tripleo_password')
  $tripleo_project                = hiera('nodepool_tripleo_project', 'project')
  $infracloud_vanilla_username    = hiera('nodepool_infracloud_vanilla_username', 'username')
  $infracloud_vanilla_password    = hiera('nodepool_infracloud_vanilla_password')
  $infracloud_vanilla_project     = hiera('nodepool_infracloud_vanilla_project', 'project')
  $infracloud_chocolate_username  = hiera('nodepool_infracloud_chocolate_username', 'username')
  $infracloud_chocolate_password  = hiera('nodepool_infracloud_chocolate_password')
  $infracloud_chocolate_project   = hiera('nodepool_infracloud_chocolate_project', 'project')
  $vexxhost_username              = hiera('nodepool_vexxhost_username', 'username')
  $vexxhost_password              = hiera('nodepool_vexxhost_password')
  $vexxhost_project               = hiera('nodepool_vexxhost_project', 'project')
  $citycloud_username             = hiera('nodepool_citycloud_username', 'username')
  $citycloud_password             = hiera('nodepool_citycloud_password')
  $clouds_yaml                    = template("openstack_project/nodepool/clouds.yaml.erb")

  class { 'openstack_project::server':
    sysadmins => hiera('sysadmins', []),
  }

  include openstack_project

  class { '::openstackci::nodepool_launcher':
    nodepool_ssh_private_key => hiera('zuul_worker_ssh_private_key_contents'),
    project_config_repo      => 'https://git.openstack.org/openstack-infra/project-config',
    oscc_file_contents       => $clouds_yaml,
    statsd_host              => 'graphite.openstack.org',
    revision                 => 'feature/zuulv3',
    python_version           => 3,
  }

  file { '/home/nodepool/.config/openstack/infracloud_vanilla_cacert.pem':
    ensure  => present,
    owner   => 'nodepool',
    group   => 'nodepool',
    mode    => '0600',
    content => hiera('infracloud_vanilla_ssl_cert_file_contents'),
    require => Class['::openstackci::nodepool_launcher'],
  }
  file { '/home/nodepool/.config/openstack/infracloud_chocolate_cacert.pem':
    ensure  => present,
    owner   => 'nodepool',
    group   => 'nodepool',
    mode    => '0600',
    content => hiera('infracloud_chocolate_ssl_cert_file_contents'),
    require => Class['::openstackci::nodepool_launcher'],
  }
}

# Node-OS: xenial
node /^nb0[12].openstack\.org$/ {
  $group = 'nodepool'
  # TODO(pabelanger): Move all of this back into nodepool manifest, it has
  # grown too big.
  $rackspace_username  = hiera('nodepool_rackspace_username', 'username')
  $rackspace_password  = hiera('nodepool_rackspace_password')
  $rackspace_project   = hiera('nodepool_rackspace_project', 'project')
  $hpcloud_username    = hiera('nodepool_hpcloud_username', 'username')
  $hpcloud_password    = hiera('nodepool_hpcloud_password')
  $hpcloud_project     = hiera('nodepool_hpcloud_project', 'project')
  $internap_username   = hiera('nodepool_internap_username', 'username')
  $internap_password   = hiera('nodepool_internap_password')
  $internap_project    = hiera('nodepool_internap_project', 'project')
  $ovh_username        = hiera('nodepool_ovh_username', 'username')
  $ovh_password        = hiera('nodepool_ovh_password')
  $ovh_project         = hiera('nodepool_ovh_project', 'project')
  $tripleo_username    = hiera('nodepool_tripleo_username', 'username')
  $tripleo_password    = hiera('nodepool_tripleo_password')
  $tripleo_project     = hiera('nodepool_tripleo_project', 'project')
  $infracloud_vanilla_username    = hiera('nodepool_infracloud_vanilla_username', 'username')
  $infracloud_vanilla_password    = hiera('nodepool_infracloud_vanilla_password')
  $infracloud_vanilla_project     = hiera('nodepool_infracloud_vanilla_project', 'project')
  $infracloud_chocolate_username  = hiera('nodepool_infracloud_chocolate_username', 'username')
  $infracloud_chocolate_password  = hiera('nodepool_infracloud_chocolate_password')
  $infracloud_chocolate_project   = hiera('nodepool_infracloud_chocolate_project', 'project')
  $vexxhost_username   = hiera('nodepool_vexxhost_username', 'username')
  $vexxhost_password   = hiera('nodepool_vexxhost_password')
  $vexxhost_project    = hiera('nodepool_vexxhost_project', 'project')
  $citycloud_username = hiera('nodepool_citycloud_username', 'username')
  $citycloud_password = hiera('nodepool_citycloud_password')
  $clouds_yaml = template("openstack_project/nodepool/clouds.yaml.erb")

  class { 'openstack_project::server':
    sysadmins                 => hiera('sysadmins', []),
    iptables_public_tcp_ports => [80],
  }

  include openstack_project

  class { '::openstackci::nodepool_builder':
    nodepool_ssh_public_key       => hiera('zuul_worker_ssh_public_key_contents'),
    vhost_name                    => $::fqdn,
    project_config_repo           => 'https://git.openstack.org/openstack-infra/project-config',
    oscc_file_contents            => $clouds_yaml,
    image_log_document_root       => '/var/log/nodepool/image',
    statsd_host                   => 'graphite.openstack.org',
    builder_logging_conf_template => 'openstack_project/nodepool/nodepool-builder.logging.conf.erb',
    upload_workers                => '16',
    revision                      => 'feature/zuulv3',
  }

  file { '/home/nodepool/.config/openstack/infracloud_vanilla_cacert.pem':
    ensure  => present,
    owner   => 'nodepool',
    group   => 'nodepool',
    mode    => '0600',
    content => hiera('infracloud_vanilla_ssl_cert_file_contents'),
    require => Class['::openstackci::nodepool_builder'],
  }

  file { '/home/nodepool/.config/openstack/infracloud_chocolate_cacert.pem':
    ensure  => present,
    owner   => 'nodepool',
    group   => 'nodepool',
    mode    => '0600',
    content => hiera('infracloud_chocolate_ssl_cert_file_contents'),
    require => Class['::openstackci::nodepool_builder'],
  }

  cron { 'mirror_gitgc':
    user        => 'nodepool',
    hour        => '20',
    minute      => '0',
    command     => 'find /opt/dib_cache/source-repositories/ -type d -name "*.git" -exec git --git-dir="{}" gc \; >/dev/null',
    environment => 'PATH=/usr/bin:/bin:/usr/sbin:/sbin',
    require     => Class['::openstackci::nodepool_builder'],
  }
}

# Node-OS: trusty
# Node-OS: xenial
node /^nb0[34].openstack\.org$/ {
  $group = 'nodepool'
  # TODO(pabelanger): Move all of this back into nodepool manifest, it has
  # grown too big.
  $rackspace_username  = hiera('nodepool_rackspace_username', 'username')
  $rackspace_password  = hiera('nodepool_rackspace_password')
  $rackspace_project   = hiera('nodepool_rackspace_project', 'project')
  $hpcloud_username    = hiera('nodepool_hpcloud_username', 'username')
  $hpcloud_password    = hiera('nodepool_hpcloud_password')
  $hpcloud_project     = hiera('nodepool_hpcloud_project', 'project')
  $internap_username   = hiera('nodepool_internap_username', 'username')
  $internap_password   = hiera('nodepool_internap_password')
  $internap_project    = hiera('nodepool_internap_project', 'project')
  $ovh_username        = hiera('nodepool_ovh_username', 'username')
  $ovh_password        = hiera('nodepool_ovh_password')
  $ovh_project         = hiera('nodepool_ovh_project', 'project')
  $tripleo_username    = hiera('nodepool_tripleo_username', 'username')
  $tripleo_password    = hiera('nodepool_tripleo_password')
  $tripleo_project     = hiera('nodepool_tripleo_project', 'project')
  $infracloud_vanilla_username    = hiera('nodepool_infracloud_vanilla_username', 'username')
  $infracloud_vanilla_password    = hiera('nodepool_infracloud_vanilla_password')
  $infracloud_vanilla_project     = hiera('nodepool_infracloud_vanilla_project', 'project')
  $infracloud_chocolate_username  = hiera('nodepool_infracloud_chocolate_username', 'username')
  $infracloud_chocolate_password  = hiera('nodepool_infracloud_chocolate_password')
  $infracloud_chocolate_project   = hiera('nodepool_infracloud_chocolate_project', 'project')
  $vexxhost_username   = hiera('nodepool_vexxhost_username', 'username')
  $vexxhost_password   = hiera('nodepool_vexxhost_password')
  $vexxhost_project    = hiera('nodepool_vexxhost_project', 'project')
  $citycloud_username = hiera('nodepool_citycloud_username', 'username')
  $citycloud_password = hiera('nodepool_citycloud_password')
  $clouds_yaml = template("openstack_project/nodepool/clouds.yaml.erb")
  class { 'openstack_project::server':
    sysadmins                 => hiera('sysadmins', []),
    iptables_public_tcp_ports => [80],
  }

  include openstack_project


  class { '::openstackci::nodepool_builder':
    nodepool_ssh_public_key       => hiera('zuul_worker_ssh_public_key_contents'),
    vhost_name                    => $::fqdn,
    project_config_repo           => 'https://git.openstack.org/openstack-infra/project-config',
    oscc_file_contents            => $clouds_yaml,
    image_log_document_root       => '/var/log/nodepool/image',
    statsd_host                   => 'graphite.openstack.org',
    builder_logging_conf_template => 'openstack_project/nodepool/nodepool-builder.logging.conf.erb',
    upload_workers                => '16',
  }

  file { '/home/nodepool/.config/openstack/infracloud_vanilla_cacert.pem':
    ensure  => present,
    owner   => 'nodepool',
    group   => 'nodepool',
    mode    => '0600',
    content => hiera('infracloud_vanilla_ssl_cert_file_contents'),
    require => Class['::openstackci::nodepool_builder'],
  }
  file { '/home/nodepool/.config/openstack/infracloud_chocolate_cacert.pem':
    ensure  => present,
    owner   => 'nodepool',
    group   => 'nodepool',
    mode    => '0600',
    content => hiera('infracloud_chocolate_ssl_cert_file_contents'),
    require => Class['::openstackci::nodepool_builder'],
  }

  cron { 'mirror_gitgc':
    user        => 'nodepool',
    hour        => '20',
    minute      => '0',
    command     => 'find /opt/dib_cache/source-repositories/ -type d -name "*.git" -exec git --git-dir="{}" gc \; >/dev/null',
    environment => 'PATH=/usr/bin:/bin:/usr/sbin:/sbin',
    require     => Class['::openstackci::nodepool_builder'],
  }
}

# Node-OS: xenial
node /^ze\d+\.openstack\.org$/ {
  $group = "zuul-executor"

  $gerrit_server           = 'review.openstack.org'
  $gerrit_user             = 'zuul'
  $gerrit_ssh_host_key     = hiera('gerrit_ssh_rsa_pubkey_contents')
  $gerrit_ssh_private_key  = hiera('gerrit_ssh_private_key_contents')
  $zuul_ssh_private_key    = hiera('zuul_ssh_private_key_contents')
  $zuul_static_private_key = hiera('jenkins_ssh_private_key_contents')
  $git_email               = 'zuul@openstack.org'
  $git_name                = 'OpenStack Zuul'
  $revision                = 'feature/zuulv3'

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [79],
    sysadmins                 => hiera('sysadmins', []),
    afs                       => true,
  }

  class { '::project_config':
    url => 'https://git.openstack.org/openstack-infra/project-config',
  }

  # NOTE(pabelanger): We call ::zuul directly, so we can override all in one
  # settings.
  class { '::zuul':
    gearman_server           => 'zuulv3.openstack.org',
    gerrit_server            => $gerrit_server,
    gerrit_user              => $gerrit_user,
    zuul_ssh_private_key     => $gerrit_ssh_private_key,
    git_email                => $git_email,
    git_name                 => $git_name,
    worker_private_key_file  => '/var/lib/zuul/ssh/nodepool_id_rsa',
    revision                 => $revision,
    python_version           => 3,
    zookeeper_hosts          => 'nodepool.openstack.org:2181',
    zuulv3                   => true,
    connections              => hiera('zuul_connections', []),
    gearman_client_ssl_cert  => hiera('gearman_client_ssl_cert'),
    gearman_client_ssl_key   => hiera('gearman_client_ssl_key'),
    gearman_ssl_ca           => hiera('gearman_ssl_ca'),
    #TODO(pabelanger): Add openafs role for zuul-jobs to setup /etc/openafs
    # properly. We need to revisting this post Queens PTG.
    trusted_ro_paths         => ['/etc/openafs', '/etc/ssl/certs', '/var/lib/zuul/ssh'],
    trusted_rw_paths         => ['/afs'],
    untrusted_ro_paths       => ['/etc/ssl/certs'],
    disk_limit_per_job       => 5000,  # Megabytes
    site_variables_yaml_file => $::project_config::zuul_site_variables_yaml,
    require                  => $::project_config::config_dir,
    statsd_host              => 'graphite.openstack.org',
  }

  class { '::zuul::executor': }

  # This is used by the log job submission playbook which runs under
  # python2
  package { 'gear':
    ensure   => latest,
    provider => openstack_pip,
    require  => Class['pip'],
  }

  file { '/var/lib/zuul/ssh/nodepool_id_rsa':
    owner   => 'zuul',
    group   => 'zuul',
    mode    => '0400',
    require => File['/var/lib/zuul/ssh'],
    content => $zuul_ssh_private_key,
  }

  file { '/var/lib/zuul/ssh/static_id_rsa':
    owner   => 'zuul',
    group   => 'zuul',
    mode    => '0400',
    require => File['/var/lib/zuul/ssh'],
    content => $zuul_static_private_key,
  }

  class { '::zuul::known_hosts':
    known_hosts_content => "review.openstack.org,104.130.246.91,2001:4800:7819:103:be76:4eff:fe05:8525 ${gerrit_ssh_host_key}",
  }
}

# Node-OS: trusty
node 'zuulv3-dev.openstack.org' {
  $gerrit_server        = 'review.openstack.org'
  $gerrit_user          = 'zuul'
  $gerrit_ssh_host_key  = hiera('gerrit_zuul_user_ssh_key_contents')
  $zuul_ssh_private_key = hiera('zuul_ssh_private_key_contents')
  $zuul_url             = "http://${::fqdn}/p"
  $git_email            = 'zuul@openstack.org'
  $git_name             = 'OpenStack Zuul'
  $revision             = 'feature/zuulv3'

  $gearman_workers = []
  $iptables_rules = regsubst ($gearman_workers, '^(.*)$', '-m state --state NEW -m tcp -p tcp --dport 4730 -s \1 -j ACCEPT')

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80],
    iptables_rules6           => $iptables_rules,
    iptables_rules4           => $iptables_rules,
    sysadmins                 => hiera('sysadmins', []),
  }

  # NOTE(pabelanger): We call ::zuul directly, so we can override all in one
  # settings.
  class { '::zuul':
    gerrit_server        => $gerrit_server,
    gerrit_user          => $gerrit_user,
    zuul_ssh_private_key => $zuul_ssh_private_key,
    git_email            => $git_email,
    git_name             => $git_name,
    revision             => $revision,
  }

  class { 'openstack_project::zuul_merger':
    gerrit_server        => $gerrit_server,
    gerrit_user          => $gerrit_user,
    gerrit_ssh_host_key  => $gerrit_ssh_host_key,
    zuul_ssh_private_key => $zuul_ssh_private_key,
    revision             => $revision,
    manage_common_zuul   => false,
  }
  # TODO(pabelanger): Add zuul_scheduler support
}

# Node-OS: xenial
node 'zuulv3.openstack.org' {
  $gerrit_server        = 'review.openstack.org'
  $gerrit_user          = 'zuul'
  $gerrit_ssh_host_key  = hiera('gerrit_zuul_user_ssh_key_contents')
  $zuul_ssh_private_key = hiera('zuul_ssh_private_key_contents')
  $zuul_url             = "http://${::fqdn}/p"
  $git_email            = 'zuul@openstack.org'
  $git_name             = 'OpenStack Zuul'
  $revision             = 'feature/zuulv3'

  $gearman_workers = [
    'ze01.openstack.org',
    'ze02.openstack.org',
    'ze03.openstack.org',
    'ze04.openstack.org',
    'ze05.openstack.org',
    'ze06.openstack.org',
    'ze07.openstack.org',
    'ze08.openstack.org',
    'ze09.openstack.org',
    'ze10.openstack.org',
    'zm01.openstack.org',
    'zm02.openstack.org',
    'zm03.openstack.org',
    'zm04.openstack.org',
    'zm05.openstack.org',
    'zm06.openstack.org',
    'zm07.openstack.org',
    'zm08.openstack.org',
  ]
  $iptables_rules = regsubst ($gearman_workers, '^(.*)$', '-m state --state NEW -m tcp -p tcp --dport 4730 -s \1 -j ACCEPT')

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80, 443],
    iptables_rules6           => $iptables_rules,
    iptables_rules4           => $iptables_rules,
    sysadmins                 => hiera('sysadmins', []),
  }

  class { '::project_config':
    url => 'https://git.openstack.org/openstack-infra/project-config',
  }

  # NOTE(pabelanger): We call ::zuul directly, so we can override all in one
  # settings.
  class { '::zuul':
    gerrit_server                => $gerrit_server,
    gerrit_user                  => $gerrit_user,
    zuul_ssh_private_key         => $zuul_ssh_private_key,
    git_email                    => $git_email,
    git_name                     => $git_name,
    revision                     => $revision,
    python_version               => 3,
    zookeeper_hosts              => 'nodepool.openstack.org:2181',
    zookeeper_session_timeout    => 40,
    zuulv3                       => true,
    connections                  => hiera('zuul_connections', []),
    connection_secrets           => hiera('zuul_connection_secrets', []),
    zuul_status_url              => 'http://127.0.0.1:8001/openstack',
    zuul_web_url                 => 'http://127.0.0.1:9000/openstack',
    gearman_client_ssl_cert      => hiera('gearman_client_ssl_cert'),
    gearman_client_ssl_key       => hiera('gearman_client_ssl_key'),
    gearman_server_ssl_cert      => hiera('gearman_server_ssl_cert'),
    gearman_server_ssl_key       => hiera('gearman_server_ssl_key'),
    gearman_ssl_ca               => hiera('gearman_ssl_ca'),
    proxy_ssl_cert_file_contents => hiera('zuul_ssl_cert_file_contents'),
    proxy_ssl_key_file_contents  => hiera('zuul_ssl_key_file_contents'),
    statsd_host                  => 'graphite.openstack.org',
  }

  file { "/etc/zuul/github.key":
    ensure  => present,
    owner   => 'zuul',
    group   => 'zuul',
    mode    => '0600',
    content => hiera('zuul_github_app_key'),
    require => File['/etc/zuul'],
  }

  class { '::zuul::scheduler':
    layout_dir     => $::project_config::zuul_layout_dir,
    require        => $::project_config::config_dir,
    python_version => 3,
    use_mysql      => true,
  }

  class { '::zuul::web': }

  include bup
  bup::site { 'rax.ord':
    backup_user   => 'bup-zuulv3',
    backup_server => 'backup01.ord.rax.ci.openstack.org',
  }

}

# Node-OS: trusty
node 'zuul.openstack.org' {
  $gearman_workers = [
    'nodepool.openstack.org',
  ]
  $iptables_rules = regsubst ($gearman_workers, '^(.*)$', '-m state --state NEW -m tcp -p tcp --dport 4730 -s \1 -j ACCEPT')

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80, 443],
    iptables_rules6           => $iptables_rules,
    iptables_rules4           => $iptables_rules,
    sysadmins                 => hiera('sysadmins', []),
  }

  class { 'openstack_project::zuul_prod':
    project_config_repo            => 'https://git.openstack.org/openstack-infra/project-config',
    gerrit_server                  => 'review.openstack.org',
    gerrit_user                    => 'jenkins',
    gerrit_ssh_host_key            => hiera('gerrit_ssh_rsa_pubkey_contents'),
    zuul_ssh_private_key           => hiera('zuul_ssh_private_key_contents'),
    url_pattern                    => 'http://logs.openstack.org/{build.parameters[LOG_PATH]}',
    proxy_ssl_cert_file_contents   => hiera('zuul_ssl_cert_file_contents'),
    proxy_ssl_key_file_contents    => hiera('zuul_ssl_key_file_contents'),
    proxy_ssl_chain_file_contents  => hiera('zuul_ssl_chain_file_contents'),
    zuul_url                       => 'http://zuul.openstack.org/p',
    statsd_host                    => 'graphite.openstack.org',
  }
}

# Node-OS: xenial
node /^zm\d+.openstack\.org$/ {
  $group = "zuul-merger"

  $gerrit_server        = 'review.openstack.org'
  $gerrit_user          = 'zuul'
  $gerrit_ssh_host_key  = hiera('gerrit_ssh_rsa_pubkey_contents')
  $zuul_ssh_private_key = hiera('zuulv3_ssh_private_key_contents')
  $zuul_url             = "http://${::fqdn}/p"
  $git_email            = 'zuul@openstack.org'
  $git_name             = 'OpenStack Zuul'
  $revision             = 'feature/zuulv3'

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80],
    sysadmins                 => hiera('sysadmins', []),
  }

  # NOTE(pabelanger): We call ::zuul directly, so we can override all in one
  # settings.
  class { '::zuul':
    gearman_server          => 'zuulv3.openstack.org',
    gerrit_server           => $gerrit_server,
    gerrit_user             => $gerrit_user,
    zuul_ssh_private_key    => $zuul_ssh_private_key,
    git_email               => $git_email,
    git_name                => $git_name,
    revision                => $revision,
    python_version          => 3,
    zookeeper_hosts         => 'nodepool.openstack.org:2181',
    zuulv3                  => true,
    connections             => hiera('zuul_connections', []),
    gearman_client_ssl_cert => hiera('gearman_client_ssl_cert'),
    gearman_client_ssl_key  => hiera('gearman_client_ssl_key'),
    gearman_ssl_ca          => hiera('gearman_ssl_ca'),
    statsd_host             => 'graphite.openstack.org',
  }

  class { 'openstack_project::zuul_merger':
    gerrit_server        => $gerrit_server,
    gerrit_user          => $gerrit_user,
    gerrit_ssh_host_key  => $gerrit_ssh_host_key,
    zuul_ssh_private_key => $zuul_ssh_private_key,
    manage_common_zuul   => false,
  }
}

# Node-OS: trusty
node 'zuul-dev.openstack.org' {
  $gearman_workers = []
  $iptables_rules = regsubst ($gearman_workers, '^(.*)$', '-m state --state NEW -m tcp -p tcp --dport 4730 -s \1 -j ACCEPT')

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80],
    iptables_rules6           => $iptables_rules,
    iptables_rules4           => $iptables_rules,
    sysadmins                 => hiera('sysadmins', []),
  }

  class { 'openstack_project::zuul_dev':
    project_config_repo  => 'https://git.openstack.org/openstack-infra/project-config',
    gerrit_server        => 'review-dev.openstack.org',
    gerrit_user          => 'jenkins',
    gerrit_ssh_host_key  => hiera('gerrit_dev_ssh_rsa_pubkey_contents'),
    zuul_ssh_private_key => hiera('zuul_dev_ssh_private_key_contents'),
    url_pattern          => 'http://logs.openstack.org/{build.parameters[LOG_PATH]}',
    zuul_url             => 'http://zuul-dev.openstack.org/p',
    statsd_host          => 'graphite.openstack.org',
  }
}

# Node-OS: trusty
node 'pbx.openstack.org' {
  class { 'openstack_project::server':
    sysadmins                 => hiera('sysadmins', []),
    # SIP signaling is either TCP or UDP port 5060.
    # RTP media (audio/video) uses a range of UDP ports.
    iptables_public_tcp_ports => [5060],
    iptables_public_udp_ports => [5060],
    iptables_rules4           => ['-m udp -p udp --dport 10000:20000 -j ACCEPT'],
    iptables_rules6           => ['-m udp -p udp --dport 10000:20000 -j ACCEPT'],
  }
  class { 'openstack_project::pbx':
    sip_providers => [
      {
        provider => 'voipms',
        hostname => 'dallas.voip.ms',
        username => hiera('voipms_username', 'username'),
        password => hiera('voipms_password'),
        outgoing => false,
      },
    ],
  }
}

# Node-OS: xenial
# A backup machine.  Don't run cron or puppet agent on it.
node /^backup\d+\..*\.ci\.openstack\.org$/ {
  $group = "ci-backup"
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [],
    manage_exim => false,
    purge_apt_sources => false,
  }
  include openstack_project::backup_server
}

# Node-OS: trusty
node 'openstackid.org' {
  class { 'openstack_project::openstackid_prod':
    sysadmins                   => hiera('sysadmins', []),
    site_admin_password         => hiera('openstackid_site_admin_password'),
    id_mysql_host               => hiera('openstackid_id_mysql_host', 'localhost'),
    id_mysql_password           => hiera('openstackid_id_mysql_password'),
    id_mysql_user               => hiera('openstackid_id_mysql_user', 'username'),
    id_db_name                  => hiera('openstackid_id_db_name'),
    ss_mysql_host               => hiera('openstackid_ss_mysql_host', 'localhost'),
    ss_mysql_password           => hiera('openstackid_ss_mysql_password'),
    ss_mysql_user               => hiera('openstackid_ss_mysql_user', 'username'),
    ss_db_name                  => hiera('openstackid_ss_db_name', 'username'),
    redis_password              => hiera('openstackid_redis_password'),
    ssl_cert_file_contents      => hiera('openstackid_ssl_cert_file_contents'),
    ssl_key_file_contents       => hiera('openstackid_ssl_key_file_contents'),
    ssl_chain_file_contents     => hiera('openstackid_ssl_chain_file_contents'),
    id_recaptcha_public_key     => hiera('openstackid_recaptcha_public_key'),
    id_recaptcha_private_key    => hiera('openstackid_recaptcha_private_key'),
    app_url                     => 'https://openstackid.org',
    app_key                     => hiera('openstackid_app_key'),
    id_log_error_to_email       => 'openstack@tipit.net',
    id_log_error_from_email     => 'noreply@openstack.org',
    email_driver                => 'smtp',
    email_smtp_server           => 'smtp.sendgrid.net',
    email_smtp_server_user      => hiera('openstackid_smtp_user'),
    email_smtp_server_password  => hiera('openstackid_smtp_password'),
  }
}

# Node-OS: trusty
node 'openstackid-dev.openstack.org' {
  class { 'openstack_project::openstackid_dev':
    sysadmins                   => hiera('sysadmins', []),
    site_admin_password         => hiera('openstackid_dev_site_admin_password'),
    id_mysql_host               => hiera('openstackid_dev_id_mysql_host', 'localhost'),
    id_mysql_password           => hiera('openstackid_dev_id_mysql_password'),
    id_mysql_user               => hiera('openstackid_dev_id_mysql_user', 'username'),
    ss_mysql_host               => hiera('openstackid_dev_ss_mysql_host', 'localhost'),
    ss_mysql_password           => hiera('openstackid_dev_ss_mysql_password'),
    ss_mysql_user               => hiera('openstackid_dev_ss_mysql_user', 'username'),
    ss_db_name                  => hiera('openstackid_dev_ss_db_name', 'username'),
    redis_password              => hiera('openstackid_dev_redis_password'),
    ssl_cert_file_contents      => hiera('openstackid_dev_ssl_cert_file_contents'),
    ssl_key_file_contents       => hiera('openstackid_dev_ssl_key_file_contents'),
    ssl_chain_file_contents     => hiera('openstackid_dev_ssl_chain_file_contents'),
    id_recaptcha_public_key     => hiera('openstackid_dev_recaptcha_public_key'),
    id_recaptcha_private_key    => hiera('openstackid_dev_recaptcha_private_key'),
    app_url                     => 'https://openstackid-dev.openstack.org',
    app_key                     => hiera('openstackid_dev_app_key'),
    id_log_error_to_email       => 'openstack@tipit.net',
    id_log_error_from_email     => 'noreply@openstack.org',
    email_driver                => 'smtp',
    email_smtp_server           => 'smtp.sendgrid.net',
    email_smtp_server_user      => hiera('openstackid_dev_smtp_user'),
    email_smtp_server_password  => hiera('openstackid_dev_smtp_password'),
  }
}

# Node-OS: trusty
# Used for testing all-in-one deployments
node 'single-node-ci.test.only' {
  include ::openstackci::single_node_ci
}

# Node-OS: trusty
node 'kdc01.openstack.org' {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [88, 464, 749, 754],
    iptables_public_udp_ports => [88, 464, 749],
    sysadmins                 => hiera('sysadmins', []),
  }

  class { 'openstack_project::kdc': }
}

# Node-OS: trusty
node 'kdc02.openstack.org' {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [88, 464, 749, 754],
    iptables_public_udp_ports => [88, 464, 749],
    sysadmins                 => hiera('sysadmins', []),
  }

  class { 'openstack_project::kdc':
    slave => true,
  }
}

# Node-OS: xenial
node 'kdc04.openstack.org' {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [88, 464, 749, 754],
    iptables_public_udp_ports => [88, 464, 749],
    sysadmins                 => hiera('sysadmins', []),
  }

  class { 'openstack_project::kdc':
    slave => true,
  }
}

# Node-OS: trusty
node 'afsdb01.openstack.org' {
  $group = "afsdb"

  class { 'openstack_project::server':
    iptables_public_udp_ports => [7000,7002,7003,7004,7005,7006,7007],
    sysadmins                 => hiera('sysadmins', []),
    afs                       => true,
    manage_exim               => true,
  }

  include openstack_project::afsdb
  include openstack_project::afsrelease
}

# Node-OS: trusty
node /^afsdb.*\.openstack\.org$/ {
  $group = "afsdb"

  class { 'openstack_project::server':
    iptables_public_udp_ports => [7000,7002,7003,7004,7005,7006,7007],
    sysadmins                 => hiera('sysadmins', []),
    afs                       => true,
    manage_exim               => true,
  }

  include openstack_project::afsdb
}

# Node-OS: trusty
node /^afs.*\..*\.openstack\.org$/ {
  $group = "afs"

  class { 'openstack_project::server':
    iptables_public_udp_ports => [7000,7002,7003,7004,7005,7006,7007],
    sysadmins                 => hiera('sysadmins', []),
    afs                       => true,
    manage_exim               => true,
  }

  include openstack_project::afsfs
}

# Node-OS: trusty
node 'ask.openstack.org' {

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [22, 80, 443],
    sysadmins                 => hiera('sysadmins', []),
  }

  class { 'openstack_project::ask':
    db_user                      => hiera('ask_db_user', 'ask'),
    db_password                  => hiera('ask_db_password'),
    redis_password               => hiera('ask_redis_password'),
    site_ssl_cert_file_contents  => hiera('ask_site_ssl_cert_file_contents', undef),
    site_ssl_key_file_contents   => hiera('ask_site_ssl_key_file_contents', undef),
    site_ssl_chain_file_contents => hiera('ask_site_ssl_chain_file_contents', undef),
  }
}

# Node-OS: trusty
node 'ask-staging.openstack.org' {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [22, 80, 443],
    sysadmins                 => hiera('sysadmins', []),
  }

  class { 'openstack_project::ask_staging':
    db_password                  => hiera('ask_staging_db_password'),
    redis_password               => hiera('ask_staging_redis_password'),
  }
}

# Node-OS: trusty
# Node-OS: xenial
node /^translate\d+\.openstack\.org$/ {
  $group = "translate"
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80, 443],
    sysadmins                 => hiera('sysadmins', []),
  }
  class { 'openstack_project::translate':
    admin_users                => 'aeng,cboylan,eumel8,ianw,ianychoi,infra,jaegerandi,mordred,stevenk',
    openid_url                 => 'https://openstackid.org',
    listeners                  => ['ajp'],
    from_address               => 'noreply@openstack.org',
    mysql_host                 => hiera('translate_mysql_host', 'localhost'),
    mysql_password             => hiera('translate_mysql_password'),
    zanata_server_user         => hiera('proposal_zanata_user'),
    zanata_server_api_key      => hiera('proposal_zanata_api_key'),
    zanata_wildfly_version     => '10.1.0',
    zanata_wildfly_install_url => 'https://repo1.maven.org/maven2/org/wildfly/wildfly-dist/10.1.0.Final/wildfly-dist-10.1.0.Final.tar.gz',
    zanata_url                 => 'https://github.com/zanata/zanata-server/releases/download/server-3.9.6/zanata-3.9.6-wildfly.zip',
    zanata_checksum            => 'cb7a477f46a118a337b59b9f4004ef7e6c77a1a8',
    project_config_repo        => 'https://git.openstack.org/openstack-infra/project-config',
    ssl_cert_file_contents     => hiera('translate_ssl_cert_file_contents'),
    ssl_key_file_contents      => hiera('translate_ssl_key_file_contents'),
    ssl_chain_file_contents    => hiera('translate_ssl_chain_file_contents'),
    vhost_name                 => 'translate.openstack.org',
  }
}

# Node-OS: trusty
# Node-OS: xenial
node /^translate-dev\d*\.openstack\.org$/ {
  $group = "translate-dev"
  class { 'openstack_project::translate_dev':
    sysadmins             => hiera('sysadmins', []),
    admin_users           => 'aeng,cboylan,eumel,eumel8,ianw,ianychoi,infra,jaegerandi,mordred,stevenk',
    openid_url            => 'https://openstackid-dev.openstack.org',
    listeners             => ['ajp'],
    from_address          => 'noreply@openstack.org',
    mysql_host            => hiera('translate_dev_mysql_host', 'localhost'),
    mysql_password        => hiera('translate_dev_mysql_password'),
    zanata_server_user    => hiera('proposal_zanata_user'),
    zanata_server_api_key => hiera('proposal_zanata_api_key'),
    project_config_repo   => 'https://git.openstack.org/openstack-infra/project-config',
    vhost_name            => 'translate-dev.openstack.org',
  }
}


# Node-OS: trusty
node 'odsreg.openstack.org' {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80],
    sysadmins                 => hiera('sysadmins', []),
  }
  realize (
    User::Virtual::Localuser['ttx'],
  )
  class { '::odsreg':
  }
}

# Node-OS: trusty
# Node-OS: xenial
node /^codesearch\d*\.openstack\.org$/ {
  $group = "codesearch"
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80],
    sysadmins                 => hiera('sysadmins', []),
  }
  class { 'openstack_project::codesearch':
    project_config_repo => 'https://git.openstack.org/openstack-infra/project-config',
  }
}

# Node-OS: trusty
node 'controller00.vanilla.ic.openstack.org' {
  $group = 'infracloud'
  class { '::openstack_project::server':
    iptables_public_tcp_ports => [80,5000,5671,8774,9292,9696,35357], # logs,keystone,rabbit,nova,glance,neutron,keystone
    sysadmins                 => hiera('sysadmins', []),
    enable_unbound            => false,
    purge_apt_sources         => false,
  }
  class { '::openstack_project::infracloud::controller':
    keystone_rabbit_password         => hiera('keystone_rabbit_password'),
    neutron_rabbit_password          => hiera('neutron_rabbit_password'),
    nova_rabbit_password             => hiera('nova_rabbit_password'),
    root_mysql_password              => hiera('infracloud_mysql_password'),
    keystone_mysql_password          => hiera('keystone_mysql_password'),
    glance_mysql_password            => hiera('glance_mysql_password'),
    neutron_mysql_password           => hiera('neutron_mysql_password'),
    nova_mysql_password              => hiera('nova_mysql_password'),
    keystone_admin_password          => hiera('keystone_admin_password'),
    glance_admin_password            => hiera('glance_admin_password'),
    neutron_admin_password           => hiera('neutron_admin_password'),
    nova_admin_password              => hiera('nova_admin_password'),
    keystone_admin_token             => hiera('keystone_admin_token'),
    ssl_key_file_contents            => hiera('ssl_key_file_contents'),
    ssl_cert_file_contents           => hiera('infracloud_vanilla_ssl_cert_file_contents'),
    br_name                          => hiera('bridge_name'),
    controller_public_address        => $::fqdn,
    neutron_subnet_cidr              => '15.184.64.0/19',
    neutron_subnet_gateway           => '15.184.64.1',
    neutron_subnet_allocation_pools  => [
                                          'start=15.184.65.2,end=15.184.65.254',
                                          'start=15.184.66.2,end=15.184.66.254',
                                          'start=15.184.67.2,end=15.184.67.254'
                                        ],
    mysql_max_connections            => hiera('mysql_max_connections'),
  }
}

node /^compute\d{3}\.vanilla\.ic\.openstack\.org$/ {
  $group = 'infracloud'
  class { '::openstack_project::server':
    sysadmins                 => hiera('sysadmins', []),
    enable_unbound            => false,
    purge_apt_sources         => false,
  }
  class { '::openstack_project::infracloud::compute':
    nova_rabbit_password             => hiera('nova_rabbit_password'),
    neutron_rabbit_password          => hiera('neutron_rabbit_password'),
    neutron_admin_password           => hiera('neutron_admin_password'),
    ssl_key_file_contents            => hiera('ssl_key_file_contents'),
    ssl_cert_file_contents           => hiera('infracloud_vanilla_ssl_cert_file_contents'),
    br_name                          => hiera('bridge_name'),
    controller_public_address        => 'controller00.vanilla.ic.openstack.org',
  }
}

# Node-OS: trusty
node 'controller00.chocolate.ic.openstack.org' {
  $group = 'infracloud'
  class { '::openstack_project::server':
    iptables_public_tcp_ports => [80,5000,5671,8774,9292,9696,35357], # logs,keystone,rabbit,nova,glance,neutron,keystone
    sysadmins                 => hiera('sysadmins', []),
    enable_unbound            => false,
    purge_apt_sources         => false,
  }
  class { '::openstack_project::infracloud::controller':
    keystone_rabbit_password         => hiera('keystone_rabbit_password'),
    neutron_rabbit_password          => hiera('neutron_rabbit_password'),
    nova_rabbit_password             => hiera('nova_rabbit_password'),
    root_mysql_password              => hiera('infracloud_mysql_password'),
    keystone_mysql_password          => hiera('keystone_mysql_password'),
    glance_mysql_password            => hiera('glance_mysql_password'),
    neutron_mysql_password           => hiera('neutron_mysql_password'),
    nova_mysql_password              => hiera('nova_mysql_password'),
    keystone_admin_password          => hiera('keystone_admin_password'),
    glance_admin_password            => hiera('glance_admin_password'),
    neutron_admin_password           => hiera('neutron_admin_password'),
    nova_admin_password              => hiera('nova_admin_password'),
    keystone_admin_token             => hiera('keystone_admin_token'),
    ssl_key_file_contents            => hiera('infracloud_chocolate_ssl_key_file_contents'),
    ssl_cert_file_contents           => hiera('infracloud_chocolate_ssl_cert_file_contents'),
    br_name                          => 'br-vlan2551',
    controller_public_address        => $::fqdn,
    neutron_subnet_cidr              => '15.184.64.0/19',
    neutron_subnet_gateway           => '15.184.64.1',
    neutron_subnet_allocation_pools  => [
                                          'start=15.184.68.2,end=15.184.68.254',
                                          'start=15.184.69.2,end=15.184.69.254',
                                          'start=15.184.70.2,end=15.184.70.254'
                                        ]
  }
}

node /^compute\d{3}\.chocolate\.ic\.openstack\.org$/ {
  $group = 'infracloud'
  class { '::openstack_project::server':
    sysadmins                 => hiera('sysadmins', []),
    enable_unbound            => false,
    purge_apt_sources         => false,
  }
  class { '::openstack_project::infracloud::compute':
    nova_rabbit_password             => hiera('nova_rabbit_password'),
    neutron_rabbit_password          => hiera('neutron_rabbit_password'),
    neutron_admin_password           => hiera('neutron_admin_password'),
    ssl_key_file_contents            => hiera('infracloud_chocolate_ssl_key_file_contents'),
    ssl_cert_file_contents           => hiera('infracloud_chocolate_ssl_cert_file_contents'),
    br_name                          => 'br-vlan2551',
    controller_public_address        => 'controller00.chocolate.ic.openstack.org',
  }
}

# Node-OS: trusty
# Upgrade-Modules
node /^baremetal\d{2}\.vanilla\.ic\.openstack\.org$/ {
  $group = 'infracloud'
  class { '::openstack_project::server':
    iptables_public_udp_ports => [67,69],
    sysadmins                 => hiera('sysadmins', []),
    enable_unbound            => false,
    purge_apt_sources         => false,
  }

  class { '::openstack_project::infracloud::baremetal':
    ironic_inventory          => hiera('ironic_inventory', {}),
    ironic_db_password        => hiera('ironic_db_password'),
    mysql_password            => hiera('bifrost_mysql_password'),
    ipmi_passwords            => hiera('ipmi_passwords'),
    ssh_private_key           => hiera('bifrost_vanilla_ssh_private_key'),
    ssh_public_key            => hiera('bifrost_vanilla_ssh_public_key'),
    bridge_name               => hiera('bridge_name'),
    vlan                      => hiera('vlan'),
    gateway_ip                => hiera('gateway_ip'),
    default_network_interface => hiera('default_network_interface'),
    dhcp_pool_start           => hiera('dhcp_pool_start'),
    dhcp_pool_end             => hiera('dhcp_pool_end'),
    network_interface         => hiera('network_interface'),
    ipv4_nameserver           => hiera('ipv4_nameserver'),
    ipv4_subnet_mask          => hiera('ipv4_subnet_mask'),
  }
}

# vim:sw=2:ts=2:expandtab:textwidth=79
