#!/bin/bash -xe

# If a bundle file is present, call tox with the jenkins version of
# the test environment so it is used.  Otherwise, use the normal
# (non-bundle) test environment.  Also, run pip freeze on the
# resulting environment at the end so that we have a record of exactly
# what packages we ended up testing.
#

venv=venv

VDISPLAY=99
DIMENSIONS='1280x1024x24'
/usr/bin/Xvfb :${VDISPLAY} -screen 0 ${DIMENSIONS} 2>&1 > /dev/null

DISPLAY=:${VDISPLAY} tox -e$venv -- ./run_tests.sh -N --with-selenium
result=$?

pkill Xvfb 2>&1 > /dev/null

echo "Begin pip freeze output from test virtualenv:"
echo "======================================================================"
.tox/$venv/bin/pip freeze
echo "======================================================================"

exit $result
