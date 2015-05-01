#!/usr/bin/env python
#
# Copyright 2015 Hewlett-Packard Development Company, L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

"""
This is a simple test server that serves up the web content locally
as if it was a working remote server. It also proxies all the live
date/*.json files into the local test server, so that the Ajax async
loading works without hitting Cross Site Scripting violations.
"""

import argparse
import BaseHTTPServer
import os.path
import urllib2

import requests

SERVER_UPSTREAM = "https://review.openstack.org"
ZUUL_UPSTREAM = "https://zuul.openstack.org"


class ERHandler(BaseHTTPServer.BaseHTTPRequestHandler):
    """A request handler to create a magic local ER server"""

    def do_POST(self):
        data = self.rfile.read(int(self.headers['content-length']))
        headers = {}
        # we need to trim some of the local headers in order for this
        # request to remain valid.
        for header in self.headers:
            if header not in ("host", "origin", "connection"):
                headers[header] = self.headers[header]
        resp = requests.post("%s%s" %
                             (SERVER_UPSTREAM, self.path),
                             headers=headers,
                             data=data)

        # Process request back to client
        self.send_response(resp.status_code)
        for header in resp.headers:
            # Requests has now decoded the response so it's no longer
            # a gzip stream, which also means content-length is
            # wrong. So we remove content-encoding, then drop
            # content-length because if provided Gerrit strictly uses
            # it for reads. We also drop all the keep-alive related
            # headers, our server doesn't do that.
            if header not in ("connection", "content-length",
                              "keep-alive", "content-encoding"):
                self.send_header(header, resp.headers[header])
        self.end_headers()
        self.wfile.write(resp.text)

    def do_GET(self):
        # possible local file path
        local_path = self.path.replace('/static/', '').split('?')[0]

        # if the file exists locally, we'll serve it up directly
        if os.path.isfile(local_path):
            self.send_response(200, "Success")
            self.end_headers()
            with open(local_path) as f:
                for line in f.readlines():
                    # in order for us to fetch the .json files, we
                    # need to have them served from our server,
                    # otherwise browser cross site scripting
                    # protections kick in. So rewrite content on the
                    # fly for those redirects.
                    line = line.replace(
                        "review.openstack.org",
                        "localhost:%s" % self.server.server_port)
                    line = line.replace(
                        "https://zuul.openstack.org",
                        "http://localhost:%s" % self.server.server_port)
                    self.wfile.write(line)
            print "Loaded from local override"
            return

        # First we'll look for a zuul status call
        if self.path.startswith("/status"):
            try:
                zuul_url = "%s%s" % (ZUUL_UPSTREAM, self.path)
                response = urllib2.urlopen(zuul_url)
                self.send_response(200, "Success")
                for header in response.info():
                    self.send_header(header, response.info()[header])
                self.end_headers()

                for line in response.readlines():
                    line = line.replace(
                        "review.openstack.org",
                        "localhost:%s" % self.server.server_port)
                    line = line.replace(
                        "https://zuul.openstack.org",
                        "http://localhost:%s" % self.server.server_port)
                self.wfile.write(line)
                return
            except urllib2.HTTPError as e:
                self.send_response(e.code)
                self.end_headers()
                self.wfile.write(e.read())
                return
            except urllib2.URLError:
                print "URL %s not found" % (zuul_url)

        # If you've not built local data to test with, instead grab
        # the data off the production server on the fly and serve it
        # up from our server.
        try:
            response = urllib2.urlopen("%s%s" %
                                       (SERVER_UPSTREAM, self.path))
            self.send_response(200, "Success")
            for header in response.info():
                self.send_header(header, response.info()[header])
            self.end_headers()

            for line in response.readlines():
                line = line.replace(
                    "review.openstack.org",
                    "localhost:%s" % self.server.server_port)
                line = line.replace(
                    "https://zuul.openstack.org",
                    "http://localhost:%s" % self.server.server_port)
                self.wfile.write(line)
        except urllib2.HTTPError as e:
            self.send_response(e.code)
            self.end_headers()
            self.wfile.write(e.read())


def parse_opts():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('-p', '--port',
                        help='port to bind to [default: 8001]',
                        type=int,
                        default=8001)
    return parser.parse_args()


def main():
    opts = parse_opts()
    server_address = ('', opts.port)
    httpd = BaseHTTPServer.HTTPServer(server_address, ERHandler)

    print "Test Server is running at http://localhost:%s" % opts.port
    print "Ctrl-C to exit"
    print

    while True:
        httpd.handle_request()

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print "\n"
        print "Thanks for testing! Please come again."
