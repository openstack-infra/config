#!/bin/bash -xe

# Copyright 2013 OpenStack Foundation
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

org=$1
project=$2

if [[ -z "$org" || -z "$project" ]]
then
  echo "Usage: $0 ORG PROJECT"
  echo
  echo "ORG: The project organization (eg 'openstack')"
  echo "PROJECT: The project name (eg 'nova')"
  exit 1
fi

source /usr/local/jenkins/slave_scripts/select-mirror.sh $org $project

rm -f dist/*.whl
tox -evenv pip install wheel
tox -evenv python setup.py bdist_wheel

FILES=dist/*.whl
for f in $FILES
do
  echo "SHA1sum for $f:"
  sha1sum $f | awk '{print $1}' > $f.sha1
  cat $f.sha1

  echo "MD5sum for $f:"
  md5sum $f  | awk '{print $1}' > $f.md5
  cat $f.md5
done
