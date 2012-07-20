class jenkins_jobs($url, $username, $password, $site, $projects) {

  package { 'python-yaml':
    ensure => 'present'
  }

  file { '/usr/local/jenkins_jobs':
    owner => 'root',
    group => 'root',
    mode => 755,
    ensure => 'directory',
    recurse => true,
    source => ['puppet:///modules/jenkins_jobs/'],
    require => Package['python-yaml']
  }

  file { '/usr/local/jenkins_jobs/jenkins_jobs.ini':
    owner => 'root',
    group => 'root',
    mode => 440,
    ensure => 'present',
    content => template('jenkins_jobs/jenkins_jobs.ini.erb'),
    replace => 'true',
    require => File['/usr/local/jenkins_jobs']
  }

  process_projects { $projects:
    site => $site,
    require => [
      File['/usr/local/jenkins_jobs/jenkins_jobs.ini'],
      Package['python-jenkins']
      ]
  }

  package { "python-jenkins":
    ensure => latest,  # okay to use latest for pip
    provider => pip,
    require => Package[python-pip],
  }

}
