#!/bin/bash -xe

# Copyright 2014 IBM Corp.
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

# The script is to push the updated English po to Transifex.

PROJECT="horizon"

if [ ! `echo $ZUUL_REFNAME | grep master` ]
then
    exit 0
fi

git config user.name "OpenStack Jenkins"
git config user.email "jenkins@openstack.org"

# No need to initialize transifex client
# because horizon has .tx folder

# Invoke run_tests.sh to update the po files
# Or else, "../manage.py makemessages" can be used.
./run_tests.sh -N --makemessages

# Add all changed files to git
git add ${PROJECT}/locale/en/LC_MESSAGES/*
git add openstack_dashboard/locale/en/LC_MESSAGES/*

if [ ! `git diff-index --quiet HEAD --` ]
then
    # Push source file changes to transifex
    tx --debug --traceback push -s
fi

