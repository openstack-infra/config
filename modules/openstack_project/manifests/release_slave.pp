# Copyright 2012  Hewlett-Packard Development Company, L.P.
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
# Class to install dependencies for uploading releases to pypi, maven and
# similar external repositories
#
class openstack_project::release_slave (
  $pypi_password,
  $jenkins_ssh_public_key,
  $pypi_username = 'openstackci',
  $jenkinsci_username,
  $jenkinsci_password,
  $mavencentral_username,
  $mavencentral_password,
  $puppet_forge_username,
  $puppet_forge_password,
  $jenkins_gitfullname = 'OpenStack Jenkins',
  $jenkins_gitemail = 'jenkins@openstack.org',
  $project_config_repo = 'https://git.openstack.org/openstack-infra/project-config',
  $npm_username,
  $npm_userpassword,
  $npm_userurl,
) {
  class { 'openstack_project::slave':
    ssh_key             => $jenkins_ssh_public_key,
    jenkins_gitfullname => $jenkins_gitfullname,
    jenkins_gitemail    => $jenkins_gitemail,
    project_config_repo => $project_config_repo,
  }

  include pip

  package { 'twine':
    ensure   => latest,
    provider => pip,
    require  => Class['pip'],
  }

  package { 'wheel':
    ensure   => latest,
    provider => pip,
    require  => Class['pip'],
  }

  package { ['nodejs', 'nodejs-legacy', 'npm']:
    ensure => latest,
    before => [
      Exec['upgrade npm']
    ]
  }

  exec { 'assert npm@2':
    command  => 'npm install npm@2 -g --upgrade',
    path     => '/usr/local/bin:/usr/bin',
    onlyif   => '[ `npm --version | cut -c 1` = "1" ]',
    require  => [
      Package['npm'],
      File['/usr/etc/npmrc'],
    ],
  }

  exec { 'upgrade npm':
    command  => 'npm install npm -g --upgrade',
    path     => '/usr/local/bin:/usr/bin',
    onlyif   => '[ `npm view npm version` != `npm --version` ]',
    require  => Exec['assert npm@2'],
  }

  file { '/home/jenkins/.pypirc':
    ensure  => present,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0600',
    content => template('openstack_project/pypirc.erb'),
    require => File['/home/jenkins'],
  }

  file { '/home/jenkins/.npmrc':
    ensure  => present,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0600',
    content => template('openstack_project/npmrc_jenkins.erb'),
    require => File['/home/jenkins'],
  }

  file { '/usr/etc':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0666',
  }

  file { '/usr/etc/npmrc':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0666',
    content => template('openstack_project/npmrc_global.erb'),
    require => File['/usr/etc']
  }

  file { '/home/jenkins/.jenkinsci-curl':
    ensure  => present,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0600',
    content => template('openstack_project/jenkinsci-curl.erb'),
    require => File['/home/jenkins'],
  }

  file { '/home/jenkins/.mavencentral-curl':
    ensure  => present,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0600',
    content => template('openstack_project/mavencentral-curl.erb'),
    require => File['/home/jenkins'],
  }

  file { '/home/jenkins/.puppetforge.yml':
    ensure  => present,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0600',
    content => template('openstack_project/puppetforge.yml.erb'),
    require => File['/home/jenkins'],
  }

}
