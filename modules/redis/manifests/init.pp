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
# == Class: redis
# http://packages.ubuntu.com/quantal/amd64/redis-server/filelist

class redis(
  $redis_port = '6379',
  $redis_max_memory = '1gb',
  $redis_bind = '127.0.0.1',
  $redis_bin_dir = '/usr/bin',
) {

  package {'redis-server':
    ensure  => installed,
  }

  case $::redis_version {
    /2\.2\.\d+/: {
      $redis_conf_file = 'redis.2.2.conf.erb'
    }
    /2\.4\.\d+/: {
      $redis_conf_file = 'redis.2.4.conf.erb'
    }
    /2\.6\.\d+/: {
      $redis_conf_file = 'redis.2.6.conf.erb'
    }
    default: {
      fail("Invalid redis version, ${::redis_version}")
    }
  }

  file { '/etc/init.d/redis-server':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package['redis-server'],
    content => template('redis/init_script.erb'),
  }

  file { '/etc/redis/redis.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("redis/${redis_conf_file}"),
    require => Package['redis-server'],
    notify  => Service['redis'],
  }

  service { 'redis-server':
    ensure  => running,
    enable  => true,
    require => [ File['/etc/redis/redis.conf'],  File['/etc/init.d/redis-server'], Package['redis-server'] ],
  }

}
