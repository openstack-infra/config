# Copyright 2013  OpenStack Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# User group management dev server
#
class openstack_project::groups_dev (
  $admin_users = [
    'mkiss',
  ],
  $conf_cron_key = '',
  $drupal_conf_markdown_directory = '/srv/groups-static-pages',
  $drupal_conf_openid_provider = 'https://openstackid-dev.openstack.org',
  $drupal_site_name = 'groups-dev.openstack.org',
  $drupal_site_root = '/srv/vhosts/groups-dev.openstack.org',
  $site_mysql_host = '',
  $drupal_site_mysql_user = 'groups',
  $site_mysql_password = '',
  $drupal_site_mysql_database = 'groups_dev',
  $drupal_site_vhost_root = '/srv/vhosts',
  $site_admin_password = '',
  $drupal_site_alias = 'groupsdev',
  $drupal_site_profile = 'groups',
  $drupal_site_base_url = 'http://groups-dev.openstack.org',
  $drupal_package_repository = 'http://tarballs.openstack.org/groups/drupal-updates/release-history',
  $drupal_package_branch = 'dev',
  $vcsrepo_provider = 'git',
  $vcsrepo_revision = 'master',
  $vcsrepo_source = 'https://git.openstack.org/openstack-infra/groups-static-pages',
  $sysadmins = [],
  $site_ssl_cert_file_contents = undef,
  $site_ssl_key_file_contents = undef,
  $site_ssl_cert_file = '/etc/ssl/private/ssl-cert-snakeoil.key',
  $site_ssl_key_file = '/etc/ssl/private/groups-dev.openstack.org.key',
) {

  realize (
    User::Virtual::Localuser[$admin_users],
  )

#  include drupal

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [22, 80, 443],
    sysadmins                 => $sysadmins,
  }

  vcsrepo { '/srv/groups-static-pages':
    ensure   => latest,
    provider => $vcsrepo_provider,
    revision => $vcsrepo_revision,
    source   => $vcsrepo_source,
  }

  class { 'drupal':
    site_name                    => $drupal_site_name,
    site_root                    => $drupal_site_root,
    site_mysql_host              => $site_mysql_host,
    site_mysql_user              => $drupal_site_mysql_user,
    site_mysql_password          => $site_mysql_password,
    site_mysql_database          => $drupal_site_mysql_database,
    site_vhost_root              => $drupal_site_vhost_root,
    site_admin_password          => $site_admin_password,
    site_alias                   => $drupal_site_alias,
    site_profile                 => $drupal_site_profile,
    site_base_url                => $drupal_site_base_url,
    site_ssl_enabled             => true,
    site_ssl_cert_file_contents  => $site_ssl_cert_file_contents,
    site_ssl_key_file_contents   => $site_ssl_key_file_contents,
    site_ssl_cert_file           => $site_ssl_cert_file,
    site_ssl_key_file            => $site_ssl_key_file,
    package_repository           => $drupal_package_repository,
    package_branch               => $drupal_package_branch,
    conf_cron_key                => $conf_cron_key,
    conf_markdown_directory      => $drupal_conf_markdown_directory,
    conf_openid_provider         => $drupal_conf_openid_provider,
    require                      => [ Class['openstack_project::server'],
      Vcsrepo[$drupal_conf_markdown_directory] ]
  }

}
