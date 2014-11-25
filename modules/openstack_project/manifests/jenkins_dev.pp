# == Class: openstack_project::jenkins_dev
#
class openstack_project::jenkins_dev (
  $admin_users = [
    'zaro',
  ],
  $jenkins_ssh_private_key = '',
  $sysadmins = [],
  $mysql_root_password,
  $mysql_password,
  $nodepool_ssh_private_key = '',
  $jenkins_api_user = '',
  $jenkins_api_key = '',
  $jenkins_credentials_id = '',
  $jenkins_vhost_name = 'jenkins-dev.openstack.org',
  $jenkins_plugins = {
    'build-timeout' => { 'version' => '1.14' },
    'copyartifact' => { 'version' => '1.22' },
    'dashboard-view' => { 'version' => '2.3' },
    'gearman-plugin' => { 'version' => '0.1.1' },
    'git' => { 'version' => '1.1.23' },
    'greenballs' => { 'version' => '1.12' },
    'extended-read-permission' => { 'version' => '1.0' },
    'zmq-event-publisher' => { 'version' => '0.0.3' },
    # TODO(jeblair): release #'scp' => { 'version' => '1.9' },
    'monitoring' => { 'version' => '1.40.0' },
    'nodelabelparameter' => { 'version' => '1.2.1' },
    'notification' => { 'version' => '1.4' },
    'openid' => { 'version' => '1.5' },
    'publish-over-ftp' => { 'version' => '1.7' },
    'simple-theme-plugin' => { 'version' => '0.2' },
    'timestamper' => { 'version' => '1.3.1' },
    'token-macro' => { 'version' => '1.5.1' },
  },
  $jenkins_serveradmin_email = 'webmaster@openstack.org',
  $jenkins_log_filename = 'openstack.png',
  $hpcloud_username = '',
  $hpcloud_password = '',
  $hpcloud_project = '',
  $nodepool_template = 'nodepool-dev.yaml.erb',
  $use_bup = true,
  $bup_backup_user = 'bup-jenkins-dev',
  $bup_backup_server = 'ci-backup-rs-ord.openstack.org',
) {

  realize (
    User::Virtual::Localuser[$admin_users],
  )

  include openstack_project

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80, 443],
    sysadmins                 => $sysadmins,
  }

  if $use_bup {
    include bup
    bup::site { 'rs-ord':
      backup_user   => $bup_backup_user,
      backup_server => $bup_backup_server,
    }
  }

  class { '::jenkins::master':
    vhost_name              => $jenkins_vhost_name,
    serveradmin             => $jenkins_serveradmin_email,
    logo                    => $jenkins_log_filename,
    ssl_cert_file           => '/etc/ssl/certs/ssl-cert-snakeoil.pem',
    ssl_key_file            => '/etc/ssl/private/ssl-cert-snakeoil.key',
    ssl_chain_file          => '',
    jenkins_ssh_private_key => $jenkins_ssh_private_key,
    jenkins_ssh_public_key  => $openstack_project::jenkins_dev_ssh_key,
  }

  define install_jenkins_plugin($version) {
    jenkins::plugin { $name:
      version => $version,
    }
  }

  create_resources( install_jenkins_plugin, $jenkins_plugins )

  file { '/etc/default/jenkins':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/openstack_project/jenkins/jenkins.default',
  }

  class { '::nodepool':
    mysql_root_password      => $mysql_root_password,
    mysql_password           => $mysql_password,
    nodepool_ssh_private_key => $nodepool_ssh_private_key,
    environment              => {
      'NODEPOOL_SSH_KEY'     => $openstack_project::jenkins_dev_ssh_key,
    }
  }

  file { '/etc/nodepool/nodepool.yaml':
    ensure  => present,
    owner   => 'nodepool',
    group   => 'root',
    mode    => '0400',
    content => template("openstack_project/nodepool/${nodepool_template}"),
    require => [
      File['/etc/nodepool'],
      User['nodepool'],
    ],
  }

  file { '/etc/nodepool/scripts':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => true,
    force   => true,
    require => File['/etc/nodepool'],
    source  => 'puppet:///modules/openstack_project/nodepool/scripts',
  }

}
