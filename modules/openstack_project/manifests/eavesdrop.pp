# Eavesdrop server

class openstack_project::eavesdrop (
  $nickpass = '',
  $sysadmins = [],
  $statusbot_nick = '',
  $statusbot_password = '',
  $statusbot_server = '',
  $statusbot_channels = '',
  $statusbot_auth_nicks = '',
  $statusbot_wiki_user = '',
  $statusbot_wiki_password = '',
  $statusbot_wiki_url = '',
  $statusbot_wiki_pageid = '',
  $accessbot_nick = '',
  $accessbot_password = '',
) {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80],
    sysadmins                 => $sysadmins
  }
  include apache
  include meetbot

  $vhost_extra = '
  <Location /alert>
    Header set Access-Control-Allow-Origin "*"
  </Location>
  '

  meetbot::site { 'openstack':
    nick        => 'openstack',
    nickpass    => $nickpass,
    network     => 'FreeNode',
    server      => 'chat.freenode.net:7000',
    use_ssl     => 'True',
    vhost_extra => $vhost_extra,
    channels    => [
        '#heat',
        '#magnetodb',
        '#murano',
        '#openstack',
        '#openstack-barbican',
        '#openstack-blazar',
        '#openstack-ceilometer',
        '#openstack-containers',
        '#openstack-dev',
        '#openstack-dns',
        '#openstack-infra',
        '#openstack-ironic',
        '#openstack-keystone',
        '#openstack-lbaas',
        '#openstack-zaqar',
        '#openstack-meeting',
        '#openstack-meeting-alt',
        '#openstack-meeting-3',
        '#openstack-neutron',
        '#openstack-oslo',
        '#openstack-qa',
        '#openstack-relmgr-office',
        '#openstack-sahara',
        '#openstack-sdks',
        '#openstack-security',
        '#openstack-swift',
        '#openstack-trove',
        '#storyboard',
        '#tripleo',
    ],
  }

  class { 'statusbot':
    nick          => $statusbot_nick,
    password      => $statusbot_password,
    server        => $statusbot_server,
    channels      => $statusbot_channels,
    auth_nicks    => $statusbot_auth_nicks,
    wiki_user     => $statusbot_wiki_user,
    wiki_password => $statusbot_wiki_password,
    wiki_url      => $statusbot_wiki_url,
    wiki_pageid   => $statusbot_wiki_pageid,
  }

  file { '/srv/meetbot-openstack/alert':
    ensure  => link,
    target  => '/var/lib/statusbot/www',
    require => Class['statusbot'],
  }

  a2mod { 'headers':
    ensure => present,
  }

  class { 'accessbot':
    nick          => $accessbot_nick,
    password      => $accessbot_password,
    server        => $statusbot_server,
    channel_file  => 'puppet:///modules/openstack_project/accessbot/channels.yaml',
  }
}
