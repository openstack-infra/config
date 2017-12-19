# == Class: openstack_project::puppetmaster
#
class openstack_project::puppetmaster (
  $puppetmaster_clouds,
  $root_rsa_key = 'xxx',
  $puppetmaster_update_cron_interval = { min     => '*/15',
                                         hour    => '*',
                                         day     => '*',
                                         month   => '*',
                                         weekday => '*',
                                       },
  $enable_mqtt = false,
  $mqtt_hostname = 'firehose.openstack.org',
  $mqtt_port = 8883,
  $mqtt_username = 'infra',
  $mqtt_password = undef,
  $mqtt_ca_cert_contents = undef,
) {
  include logrotate

  class { '::ansible':
    ansible_hostfile    => '/etc/ansible/hosts',
    retry_files_enabled => 'False',
    ansible_version     => '2.2.1.0',
  }

  file { '/etc/ansible/hostfile':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Class['ansible'],
  }

  cron { 'updatecloudlauncher':
    user        => 'root',
    minute      => '0',
    hour        => '*/1',
    monthday    => '*',
    month       => '*',
    weekday     => '*',
    command     => 'flock -n /var/run/puppet/puppet_run_cloud_launcher.lock bash /opt/system-config/production/run_cloud_launcher.sh >> /var/log/puppet_run_cloud_launcher_cron.log 2>&1',
    environment => 'PATH=/var/lib/gems/1.8/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
  }

  cron { 'updatepuppetmaster':
    user        => 'root',
    minute      => $puppetmaster_update_cron_interval[min],
    hour        => $puppetmaster_update_cron_interval[hour],
    monthday    => $puppetmaster_update_cron_interval[day],
    month       => $puppetmaster_update_cron_interval[month],
    weekday     => $puppetmaster_update_cron_interval[weekday],
    command     => 'flock -n /var/run/puppet/puppet_run_all.lock bash /opt/system-config/production/run_all.sh >> /var/log/puppet_run_all_cron.log 2>&1',
    environment => 'PATH=/var/lib/gems/1.8/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
  }

  cron { 'updateinfracloud':
    user        => 'root',
    minute      => $puppetmaster_update_cron_interval[min],
    hour        => $puppetmaster_update_cron_interval[hour],
    monthday    => $puppetmaster_update_cron_interval[day],
    month       => $puppetmaster_update_cron_interval[month],
    weekday     => $puppetmaster_update_cron_interval[weekday],
    command     => 'flock -n /var/run/puppet/puppet_run_infracloud.lock bash /opt/system-config/production/run_infracloud.sh >> /var/log/puppet_run_infracloud_cron.log 2>&1',
    environment => 'PATH=/var/lib/gems/1.8/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
  }

  logrotate::file { 'updatepuppetmaster':
    ensure  => present,
    log     => '/var/log/puppet_run_all.log',
    options => ['compress',
      'copytruncate',
      'delaycompress',
      'missingok',
      'rotate 7',
      'daily',
      'notifempty',
    ],
    require => Cron['updatepuppetmaster'],
  }

  logrotate::file { 'updatepuppetmastercron':
    ensure  => present,
    log     => '/var/log/puppet_run_all_cron.log',
    options => ['compress',
      'copytruncate',
      'delaycompress',
      'missingok',
      'rotate 7',
      'daily',
      'notifempty',
    ],
    require => Cron['updatepuppetmaster'],
  }

  logrotate::file { 'updateinfracloud':
    ensure  => present,
    log     => '/var/log/puppet_run_all_infracloud.log',
    options => ['compress',
      'copytruncate',
      'delaycompress',
      'missingok',
      'rotate 7',
      'daily',
      'notifempty',
    ],
    require => Cron['updateinfracloud'],
  }

  logrotate::file { 'updateinfracloudcron':
    ensure  => present,
    log     => '/var/log/puppet_run_infracloud_cron.log',
    options => ['compress',
      'copytruncate',
      'delaycompress',
      'missingok',
      'rotate 7',
      'daily',
      'notifempty',
    ],
    require => Cron['updateinfracloud'],
  }

  cron { 'deleteoldreports':
    user        => 'root',
    hour        => '3',
    minute      => '0',
    command     => 'sleep $((RANDOM\%600)) && find /var/lib/puppet/reports -name \'*.yaml\' -mtime +5 -execdir rm {} \;',
    environment => 'PATH=/var/lib/gems/1.8/bin:/usr/bin:/bin:/usr/sbin:/sbin',
  }

  cron { 'deleteoldreports-json':
    user        => 'root',
    hour        => '3',
    minute      => '0',
    command     => 'sleep $((RANDOM\%600)) && find /var/lib/puppet/reports -name \'*.json\' -mtime +5 -execdir rm {} \;',
    environment => 'PATH=/var/lib/gems/1.8/bin:/usr/bin:/bin:/usr/sbin:/sbin',
  }

  file { '/etc/puppet/hieradata':
    ensure => directory,
    group  => 'puppet',
    mode   => '0750',
    owner  => 'puppet',
  }

  file { '/etc/puppet/hieradata/production':
    ensure  => directory,
    group   => 'puppet',
    mode    => '0750',
    owner   => 'root',
    recurse => true,
    require => File['/etc/puppet/hieradata'],
  }

  file { '/var/lib/puppet/reports':
    ensure => directory,
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '0750',
    }

  if ! defined(File['/root/.ssh']) {
    file { '/root/.ssh':
      ensure => directory,
      mode   => '0700',
    }
  }

  file { '/root/.ssh/id_rsa':
    ensure  => present,
    mode    => '0400',
    content => $root_rsa_key,
  }

# Cloud credentials are stored in this directory for launch-node.py.
  file { '/root/ci-launch':
    ensure => directory,
    owner  => 'root',
    group  => 'admin',
    mode   => '0750',
  }

  file { '/etc/openstack':
    ensure => directory,
    owner  => 'root',
    group  => 'admin',
    mode   => '0750',
  }

  file { '/etc/openstack/clouds.yaml':
    ensure  => present,
    owner   => 'root',
    group   => 'admin',
    mode    => '0660',
    content => template('openstack_project/puppetmaster/ansible-clouds.yaml.erb'),
  }

  file { '/etc/openstack/all-clouds.yaml':
    ensure  => present,
    owner   => 'root',
    group   => 'admin',
    mode    => '0660',
    content => template('openstack_project/puppetmaster/all-clouds.yaml.erb'),
  }

# For puppet master apache serving.
  package { 'puppetmaster-passenger':
    ensure => absent,
  }

  file { '/etc/apache2/sites-available/puppetmaster.conf':
    ensure  => absent,
  }

  file { '/etc/apache2/envvars':
    ensure  => absent,
  }

# For launch/launch-node.py.
  $pip_packages = [
    'shade',
    'python-openstackclient',
  ]
  package { $pip_packages:
    ensure   => latest,
    provider => openstack_pip,
  }
  package { 'python-paramiko':
    ensure => present,
  }
  # No longer needed with latest client libs
  package { 'python-lxml':
    ensure => absent,
  }
  package { 'libxslt1-dev':
    ensure => absent,
  }

  # For signing key management
  package { 'gnupg':
    ensure => present,
  }
  package { 'gnupg-curl':
    ensure => present,
  }
  file { '/root/signing.gnupg':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }
  file { '/root/signing.gnupg/gpg.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    source  => 'puppet:///modules/openstack_project/puppetmaster/signing.conf',
    require => File['/root/signing.gnupg'],
  }
  file { '/root/signing.gnupg/sks-keyservers.netCA.pem':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    source  => 'puppet:///modules/openstack_project/puppetmaster/sks-ca.pem',
    require => File['/root/signing.gnupg'],
  }

  # Ansible mgmt
  # TODO: Put this into its own class, maybe called bastion::ansible or something

  vcsrepo { '/opt/ansible':
    ensure   => latest,
    provider => git,
    revision => 'devel',
    source   => 'https://github.com/ansible/ansible',
  }

  file { '/etc/ansible/hosts':
    ensure  => directory,
    owner   => 'root',
    group   => 'admin',
    mode    => '0755',
  }

  file { '/etc/ansible/hosts/puppet':
    ensure => absent,
  }

  file { '/etc/ansible/hosts/openstack':
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => '/opt/ansible/contrib/inventory/openstack.py',
    replace => true,
    require => Vcsrepo['/opt/ansible'],
  }

  file { '/etc/ansible/hosts/static':
    ensure => absent,
  }

  file { '/etc/ansible/hosts/emergency':
    ensure  => present,
    owner   => 'root',
    group   => 'admin',
    mode    => '0664',
  }

  file { '/etc/ansible/hosts/generated-groups':
    ensure  => present,
    owner   => 'root',
    group   => 'admin',
    mode    => '0664',
  }

  file { '/etc/ansible/hosts/infracloud':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/openstack_project/puppetmaster/infracloud',
  }

  file { '/etc/ansible/groups.txt':
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => 'puppet:///modules/openstack_project/puppetmaster/groups.txt',
    notify => Exec['expand_groups'],
  }

  file { '/var/cache/ansible-inventory':
    ensure  => directory,
    owner   => 'root',
    group   => 'admin',
    mode    => '2775',
  }

  file { '/var/cache/ansible-inventory/ansible-inventory.cache':
    ensure  => present,
    owner   => 'root',
    group   => 'admin',
    mode    => '0664',
  }

  file { '/usr/local/bin/expand-groups.sh':
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/openstack_project/puppetmaster/expand-groups.sh',
    notify => Exec['expand_groups'],
  }

  cron { 'expandgroups':
    user        => 'root',
    minute      => 0,
    hour        => 4,
    command     => '/usr/local/bin/expand-groups.sh >> /var/log/expand_groups.log 2>&1',
    environment => 'PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
  }

  logrotate::file { 'expandgroups':
    ensure  => present,
    log     => '/var/log/expand_groups.log',
    options => ['compress',
      'copytruncate',
      'delaycompress',
      'missingok',
      'rotate 7',
      'daily',
      'notifempty',
    ],
    require => Cron['expandgroups'],
  }

  # Temporarily pin paho-mqtt to 1.2.3 since 1.3.0 won't support TLS on
  # Trusty's Python 2.7.
  if $enable_mqtt {
    package {'paho-mqtt':
      ensure   => '1.2.3',
      provider => openstack_pip,
      require  => Class['pip'],
    }

    file { '/etc/mqtt_ca_cert.pem.crt':
      ensure  => present,
      content => $mqtt_ca_cert_contents,
      replace => true,
      owner   => 'root',
      group   => 'admin',
      mode    => '0555',
    }

    file { '/etc/mqtt_client.yaml':
      owner   => 'root',
      group   => 'admin',
      mode    => '0664',
      content => template('openstack_project/puppetmaster/mqtt_client.yaml.erb'),
    }

    file { '/opt/ansible/lib/ansible/plugins/callback/mqtt.py':
      ensure => absent,
    }

    file { '/etc/ansible/callback_plugins/mqtt.py':
      owner   => 'root',
      group   => 'admin',
      mode    => '0664',
      source  => 'puppet:///modules/openstack_project/puppetmaster/mqtt.py',
      require => File['/etc/ansible/callback_plugins'],
    }
  }

  exec { 'expand_groups':
    command     => 'expand-groups.sh',
    path        => '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
    refreshonly => true,
  }

  # Certificate Authority for zuul services.
  file { '/etc/zuul-ca':
    ensure  => directory,
    owner   => 'root',
    group   => 'puppet',
    mode    => '0640',
  }

  file { '/etc/zuul-ca/openssl.cnf':
    ensure  => present,
    owner   => 'root',
    group   => 'puppet',
    mode    => '0640',
    source  => 'puppet:///modules/openstack_project/puppetmaster/zuul_ca.cnf',
    require => File['/etc/zuul-ca'],
  }

  file { '/etc/zuul-ca/certs':
    ensure  => directory,
    owner   => 'root',
    group   => 'puppet',
    mode    => '0640',
    require => File['/etc/zuul-ca'],
  }

  file { '/etc/zuul-ca/crl':
    ensure  => directory,
    owner   => 'root',
    group   => 'puppet',
    mode    => '0640',
    require => File['/etc/zuul-ca'],
  }

  file { '/etc/zuul-ca/newcerts':
    ensure  => directory,
    owner   => 'root',
    group   => 'puppet',
    mode    => '0640',
    require => File['/etc/zuul-ca'],
  }

  file { '/etc/zuul-ca/private':
    ensure  => directory,
    owner   => 'root',
    group   => 'puppet',
    mode    => '0640',
    require => File['/etc/zuul-ca'],
  }
}
