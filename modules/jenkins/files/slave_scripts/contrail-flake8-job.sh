#!/usr/bin/env bash

set -o pipefail
set -ex

export WORKSPACE=$PWD
SKIP_JOBS=$WORKSPACE/skip_jobs
if [ -f $SKIP_JOBS ]; then
    echo Jobs skipped due to jenkins.opencontrail.org:/root/ci-test/skip_jobs
    exit
fi

if [ -z $SCONS_JOBS ]; then
    export SCONS_JOBS=1
fi

if [ -z $USER ]; then
    USER=jenkins
fi

# Build unittests
function build_unittest() {
    # Goto the repo top directory.
    cd $WORKSPACE/repo

    pip install flake8
 
    flake8 $1/$2 --exit-zero 2>&1 | tee $WORKSPACE/$2_flake8.log
}

function main() {
    build_unittest $*
}

env
main $*
echo Success
