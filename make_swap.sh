#!/bin/bash

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

# If we're running on a cloud server with no swap, fix that:
if [ `grep SwapTotal /proc/meminfo | awk '{ print $2; }'` -eq 0 ]; then
    if [ -b /dev/vdb ]; then
        DEV='/dev/vdb'
    elif [ -b /dev/xvde ]; then
        DEV='/dev/xvde'
    fi

    # Avoid using config drive device for swap
    if [ -n "$DEV" ] && ! blkid | grep $DEV | grep TYPE ; then
        MEMKB=`grep MemTotal /proc/meminfo | awk '{print $2; }'`
        # Use the nearest power of two in MB as the swap size.
        # This ensures that the partitions below are aligned properly.
        MEM=`python -c "import math ; print 2**int(round(math.log($MEMKB/1024, 2)))"`
        if mount | grep ${DEV} > /dev/null; then
            echo "*** ${DEV} appears to already be mounted"
            echo "*** ${DEV} unmounting and reformating"
            umount ${DEV}
        fi

        parted ${DEV} --script -- \
          mklabel msdos \
          mkpart primary linux-swap 1 ${MEM} \
          mkpart primary ext2 ${MEM} -1
        sync
        # We are only interested in scanning $DEV, not all block devices
        sudo partprobe ${DEV}
        # The device partitions might not show up immediately, make sure
        # they are ready and available for use
        udevadm settle --timeout=0 || echo "Block device not ready yet. Waiting for up to 10 seconds for it to be ready"
        udevadm settle --timeout=10 --exit-if-exists=${DEV}1
        udevadm settle --timeout=10 --exit-if-exists=${DEV}2

        mkswap ${DEV}1
        mkfs.ext4 ${DEV}2
        swapon ${DEV}1
        mount ${DEV}2 /mnt
        rsync -a /opt/ /mnt/
        umount /mnt
        perl -nle "m,${DEV}, || print" -i /etc/fstab
        echo "${DEV}1  none  swap  sw                           0  0" >> /etc/fstab
        echo "${DEV}2  /opt  ext4  errors=remount-ro,barrier=0  0  2" >> /etc/fstab
        mount -a
    fi
fi
