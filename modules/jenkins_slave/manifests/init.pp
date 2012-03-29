class jenkins_slave($ssh_key) {

    jenkinsuser { "jenkins":
      ensure => present,
      ssh_key => "${ssh_key}"
    }

    slavecirepo { "openstack-ci":
      ensure => present,
      require => [ Package[git], File[jenkinshome] ],
    }

    devstackrepo { "devstack":
      ensure => present,
      require => [ Package[git], File[jenkinshome] ],
    }

    apt::ppa { "ppa:openstack-ci/build-depends":
      ensure => present
    }

    $packages = ["apache2",
                 "autoconf",
                 "automake",
                 "build-essential",
                 "cdbs",
                 "curl",
                 "debootstrap",
                 "devscripts",
                 "dnsmasq-base",
                 "ebtables",
                 "gawk",
                 "graphviz",
                 "iptables",
                 "kpartx",
                 "kvm",
                 "libapache2-mod-wsgi",
                 "libcurl4-gnutls-dev",
                 "libldap2-dev",
                 "libmysqlclient-dev",
                 "libsasl2-dev",
                 "libsqlite3-dev",
                 "libtool",
                 "libvirt-bin",
                 "libxml2-dev",
                 "libxslt1-dev",
                 "lxc",
                 "maven2",
		 "mercurial", # needed by pip bundle
                 "default-jdk", # jdk for building java jobs
		 "pandoc", #for docs, markdown->docbook, bug 924507
                 "parted",
                 "pep8",
                 "psmisc",
                 "pylint",
                 "python-all-dev",
                 "python-cheetah",
                 "python-libvirt",
                 "python-libxml2",
                 "python-pip",
                 "python-sphinx",
                 "python-unittest2",
                 "python-vm-builder",
                 "python3-all-dev",
                 "screen",
                 "socat",
                 "sqlite3",
                 "swig",
                 "tmpreaper",
                 "unzip",
                 "vlan",
                 "wget"]
    package { $packages:
      ensure => "latest",
      require => Apt::Ppa["ppa:openstack-ci/build-depends"],
    }

    package { "apache-libcloud":
      ensure => latest,
      provider => pip,
      require => Package[python-pip]
    }

    package { "git-review":
      ensure => latest,
      provider => pip,
      require => Package[python-pip],
    }

    cron { "updateci":
      user => jenkins,
      minute => "*/15",
      command => "cd /home/jenkins/openstack-ci && /usr/bin/git pull -q origin master",
      require => [ File[jenkinshome] ],
    }

    file { 'profilerubygems':
      name => '/etc/profile.d/rubygems.sh',
      owner => 'root',
      group => 'root',
      mode => 644,
      ensure => 'present',
      source => [
         "puppet:///modules/jenkins_slave/rubygems.sh",
       ],
    }

    cron { "tmpreaper":
      user => jenkins,
      minute => '0',
      hour   => '1',
      command => "(echo && date && /usr/sbin/tmpreaper --runtime 20m --delay 1m --mtime 1d /tmp) >> /var/log/jenkins/tmpreaper.log 2>&1",
      require => [ 
                  Package[tmpreaper], Jenkinsuser[jenkins], 
                  File['jenkinslogdir'], File['tmpreaper-logrotate'] 
                 ],
   }

   file { 'tmpreaper-cron.daily':
      name => '/etc/cron.daily/tmpreaper',
      ensure => 'absent',
   }

   file { 'jenkinslogdir':
     name => '/var/log/jenkins',
     owner => 'jenkins',
     group => 'jenkins',
     mode => 755,
     ensure => 'directory',
     require => [ Jenkinsuser[jenkins] ],
   }

   file { 'tmpreaper-logrotate':
     name => '/etc/logrotate.d/tmpreaper',
     owner => 'root',
     group => 'root',
     mode => 644,
     ensure => 'present',
     require => File['jenkinslogdir'],
     source => [
                "puppet:///modules/jenkins_slave/tmpreaper-logrotate",
               ],
   }

}
