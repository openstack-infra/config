# vim: tabstop=4 shiftwidth=4 softtabstop=4

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

import os
import urllib
import datetime
import sys
import re
import md5

source_cache = sys.argv[1]
destination_mirror = sys.argv[2]

PACKAGE_VERSION_RE = re.compile(r'(.*)-[0-9]')

packages = {}
package_count = 0

for filename in os.listdir(source_cache):
    if filename.endswith('content-type'):
        continue

    realname = urllib.unquote(filename)
    # The ? accounts for sourceforge downloads
    tarball = os.path.basename(realname).split("?")[0]
    name_match = PACKAGE_VERSION_RE.search(tarball)

    if name_match is None:
        continue
    package_name = name_match.group(1)

    version_list = packages.get(package_name, {})
    version_list[tarball] = filename
    packages[package_name] = version_list
    package_count = package_count + 1

full_html = open(os.path.join(destination_mirror, "full.html"), 'w')
simple_html = open(os.path.join(destination_mirror, "index.html"), 'w')

header = "<html><head><title>PyPI Mirror</title></head><body><h1>PyPI Mirror</h1><h2>Last update: %s</h2>\n\n" % datetime.datetime.utcnow().strftime("%c UTC")
full_html.write(header)
simple_html.write(header)

for package_name, versions in packages.items():
    destination_dir = os.path.join(destination_mirror, package_name)
    if not os.path.isdir(destination_dir):
        os.makedirs(destination_dir)
    safe_dir = urllib.quote(package_name)
    simple_html.write("<a href='%s'>%s</a><br />\n" % (safe_dir, safe_dir))
    with open(os.path.join(destination_dir, "index.html"), 'w') as index:
        index.write("""<html><head>
  <title>%s &ndash; PyPI Mirror</title>
</head><body>\n""" % package_name)
        for tarball, filename in versions.items():
            source_path = os.path.join(source_cache, filename)
            destination_path = os.path.join(destination_dir, tarball)
            with open(destination_path, 'w') as dest:
                src = open(source_path, 'r').read()
                md5sum = md5.md5(src).hexdigest()
                dest.write(src)

                safe_name = urllib.quote(tarball)

                full_html.write("<a href='%s/%s'>%s</a><br />\n" % (safe_dir,
                                                       safe_name,
                                                       safe_name))
                index.write("<a href='%s#md5=%s'>%s</a>\n" % (safe_name,
                                                             md5sum,
                                                             safe_name))
        index.write("</body></html>\n")
footer = """<p class='footer'>Generated by process_cache.py; %d
packages mirrored. </p>
</body></html>\n""" % package_count
full_html.write(footer)
full_html.close()
simple_html.write(footer)
simple_html.close()
