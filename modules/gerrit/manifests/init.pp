class gerrit($canonicalweburl='',
$openidssourl="https://login.launchpad.net/+openid",
$email='',
$github_projects = [],
$commentlinks = [ { name => 'changeid',
                  match => '(I[0-9a-f]{8,40})',
                  link => '#q,$1,n,z' },

                  { name => 'launchpad',
                  match => '([Bb]ug|[Ll][Pp])\\s*[#:]?\\s*(\\d+)',
                  link => 'https://code.launchpad.net/bugs/$2' },

                  { name => 'blueprint',
                  match => '([Bb]lue[Pp]rint|[Bb][Pp])\\s*[#:]?\\s*(\\S+)',
                  link => 'https://blueprints.launchpad.net/openstack/?searchtext=$2' },

                  ]
  ) {
  
  package { "python-dev":
    ensure => latest
  }
  package { "python-pip":
    ensure => latest,
    require => Package[python-dev]
  }
  package { "github2":
    ensure => latest,
    provider => pip,
    require => Package[python-pip]
  }
  
  if $gerrit_installed {
    #notice('Gerrit is installed')

    cron { "gerritupdateci":
      user => gerrit2,
      minute => "*/15",
      command => "sleep $((RANDOM\%60)) && cd /home/gerrit2/openstack-ci && /usr/bin/git pull -q origin master"
    }

    cron { "gerritsyncusers":
      user => gerrit2,
      minute => "*/15",
      command => "sleep $((RANDOM\%60+60)) && cd /home/gerrit2/openstack-ci && python gerrit/update_gerrit_users.py"
    }

    cron { "gerritclosepull":
      user => gerrit2,
      minute => "*/5",
      command => "sleep $((RANDOM\%60+90)) && cd /home/gerrit2/openstack-ci && python gerrit/close_pull_requests.py"
    }

    file { '/home/gerrit2/github.config':
      owner => 'root',
      group => 'root',
      mode => 444,
      ensure => 'present',
      content => template('gerrit/github.config.erb'),
      replace => 'true',
    }

    file { '/home/gerrit2/review_site/etc/replication.config':
      owner => 'root',
      group => 'root',
      mode => 444,
      ensure => 'present',
      source => 'puppet:///modules/gerrit/replication.config',
      replace => 'true',
    }

    file { '/home/gerrit2/review_site/etc/gerrit.config':
      owner => 'root',
      group => 'root',
      mode => 444,
      ensure => 'present',
      content => template('gerrit/gerrit.config.erb'),
      replace => 'true',
    }

    file { '/home/gerrit2/review_site/hooks/change-merged':
      owner => 'root',
      group => 'root',
      mode => 555,
      ensure => 'present',
      source => 'puppet:///modules/gerrit/change-merged',
      replace => 'true',
    }

    file { '/home/gerrit2/review_site/hooks/patchset-created':
      owner => 'root',
      group => 'root',
      mode => 555,
      ensure => 'present',
      source => 'puppet:///modules/gerrit/patchset-created',
      replace => 'true',
    }
    
  } else {
    notice('Gerrit is not installed')
  }

}
