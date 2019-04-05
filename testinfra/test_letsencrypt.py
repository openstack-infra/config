# Copyright 2019 Red Hat, Inc.
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

import pytest

testinfra_hosts = ['adns-letsencrypt.opendev.org',
                   'letsencrypt01.opendev.org',
                   'letsencrypt02.opendev.org']


def test_acme_zone(host):
    if host.backend.get_hostname() != 'adns-letsencrypt.opendev.org':
        pytest.skip()
    acme_opendev_zone = host.file('/var/lib/bind/zones/acme.opendev.org/zone.db')
    assert acme_opendev_zone.exists

    # On our test nodes, unbound is listening on 127.0.0.1:53; this
    # ensures the query hits bind
    query_addr = host.ansible("setup")["ansible_facts"]["ansible_default_ipv4"]["address"]
    cmd = host.run("dig -t txt acme.opendev.org @" + query_addr)
    count = 0
    for line in cmd.stdout.split('\n'):
        if line.startswith('acme.opendev.org.	60	IN	TXT'):
            count = count + 1
    if count != 6:
        # NOTE(ianw): I'm sure there's more pytest-y ways to save this
        # for debugging ...
        print(cmd.stdout)
    assert count == 6, "Did not see required number of TXT records!"

def test_certs_created(host):
    if host.backend.get_hostname() == 'letsencrypt01.opendev.org':
        domain_one = host.file(
            '/etc/letsencrypt-certs/'
            'letsencrypt01.opendev.org/letsencrypt01.opendev.org.key')
        assert domain_one.exists
        domain_two = host.file(
            '/etc/letsencrypt-certs/'
            'someotherservice.opendev.org/someotherservice.opendev.org.key')
        assert domain_two.exists

    elif host.backend.get_hostname() == 'letsencrypt02.opendev.org':
        domain_one = host.file(
            '/etc/letsencrypt-certs/'
            'letsencrypt02.opendev.org/letsencrypt02.opendev.org.key')
        assert domain_one.exists

    else:
        pytest.skip()

def test_apache_restart(host):
    if host.backend.get_hostname() == 'letsencrypt01.opendev.org':
        proc = host.process.get(user='root', comm='apache2')
        # Check that the process has been running for less than a minute
        # TODO is there a better way to check that the service was restarted?
        assert proc.time.startswith('00:00')
