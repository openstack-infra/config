#! /usr/bin/env python
# Copyright (C) 2012 OpenStack, LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

# Manage jobs in Jenkins server

import os
import argparse
import hashlib
import yaml
import jenkins
import sys
import logging
import xml.etree.ElementTree as XML
from xml.dom.ext import PrettyPrint
from StringIO import StringIO
from xml.dom.ext.reader import Sax2

logger = logging.getLogger('jenkins_jobs')
logger.setLevel(logging.INFO)

parser = argparse.ArgumentParser()
subparser = parser.add_subparsers(help='update or delete job', dest='command')
parser_update = subparser.add_parser('update')
parser_update.add_argument('name', help='name of job')
parser_update.add_argument('file', help='YAML file for update', type=file)
parser_delete = subparser.add_parser('delete')
parser_delete.add_argument('name', help='name of job')
parser.add_argument('--url', dest='url', help='Jenkins URL')
parser.add_argument('--user', dest='user', help='Jenkins user name')
parser.add_argument('--pass', dest='pass', help='Jenkins password')
options = parser.parse_args()


class YamlParser(object):
    def __init__(self, yfile):
        self.data = yaml.load_all(yfile)
        self.it = self.data.__iter__()
        self.current = ''

    def get_next_xml(self):
        self.current = self.it.next()
        return XmlParser(self.current)

    def get_name(self):
        return self.current['main']['name']


class XmlParser(object):
    def __init__(self, data):
        self.data = data
        self.xml = XML.Element('project')
        self.modules = []
        self._load_modules()
        self._build()

    def _load_modules(self):
        for modulename in self.data['modules']:
            modulename = 'modules.{name}'.format(name=modulename)
            self._register_module(modulename)

    def _register_module(self, modulename):
        classname = modulename.rsplit('.', 1)[1]
        module = __import__(modulename, fromlist=[classname])
        #logger.info("module {cname} loaded\n".format(cname=classname))
        cla = getattr(module, classname)
        self.modules.append(cla(self.data))

    def _build(self):
        XML.SubElement(self.xml, 'actions')
        description = XML.SubElement(self.xml, 'description')
        description.text = "THIS JOB IS MANAGED BY PUPPET AND WILL BE OVERWRITTEN.\n\n\
DON'T EDIT THIS JOB THROUGH THE WEB\n\n\
If you would like to make changes to this job, please see:\n\n\
https://github.com/openstack/openstack-ci-puppet\n\n\
In modules/jenkins_jobs"
        XML.SubElement(self.xml, 'keepDependencies').text = 'false'
        XML.SubElement(self.xml, 'disabled').text = self.data['main']['disabled']
        XML.SubElement(self.xml, 'blockBuildWhenDownstreamBuilding').text = 'false'
        XML.SubElement(self.xml, 'blockBuildWhenUpstreamBuilding').text = 'false'
        XML.SubElement(self.xml, 'concurrentBuild').text = 'false'
        XML.SubElement(self.xml, 'buildWrappers')
        self._insert_modules()

    def _insert_modules(self):
        for module in self.modules:
            module.gen_xml(self.xml)

    def md5(self):
        return hashlib.md5(self.output()).hexdigest()

    def output(self):
        reader = Sax2.Reader()
        docNode = reader.fromString(XML.tostring(self.xml))
        tmpStream = StringIO()
        PrettyPrint(docNode, stream=tmpStream)
        return tmpStream.getvalue() 

class CacheStorage(object):
     def __init__(self):
         self.cachefilename = os.path.expanduser('~/.jenkins_jobs_cache.yml')
         try:
             yfile = file(self.cachefilename, 'r')
         except IOError:
             self.data = {}
             return
         self.data = yaml.load(yfile)
         yfile.close()

     def set(self, job, md5):
         self.data[job] = md5
         yfile = file(self.cachefilename, 'w')
         yaml.dump(self.data, yfile)
         yfile.close()

     def has_changed(self, job, md5):
         if self.data.has_key(job) and self.data[job] == md5:
            return False
         return True
         

yparse = YamlParser(options.file)
cache = CacheStorage()
while True:
    try:
      xml = yparse.get_next_xml()
      job = yparse.get_name()
      print xml.output()
      md5 = xml.md5()
      if cache.has_changed(job, md5):
         print 'job changed, send to Jenkins, set if succeed'
         cache.set(job, md5)
      else:
         print 'job the same, do not send to Jenkins'
    except StopIteration:
      break
