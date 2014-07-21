#!/bin/bash -x

#=======================================================================================
#title           : backup.sh
#description     : This script will backup VMs used for CI host on ubuntu-precise 12043.
#author          : Vinay Mahuli
#date            : 09-July-2014
#version         : 0.1
#usage           : ./backup.sh
#notes           : NA
#=======================================================================================

isRoot=`whoami | cut -f1`
if [ $isRoot != root ]; then
        echo -e "\n You need to be root !!\n"
        exit 1
fi

DISTR=`cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -d '=' -f2`
if [ $DISTR != precise ]; then
        echo -e "\n This utility is only meant for Ubuntu Precise 12043 !!\n"
        exit 1
fi

date=`date +"%d-%m-%y"` 
day_of_week=`date +"%u"`

WORKDIR="/backups"
mkdir -p $WORKDIR

cd $WORKDIR

if [ $day_of_week -eq "7" ]; then
	FOUND_VMS=`virsh --connect qemu:///system list | tr -s ' ' | cut -d ' ' -f3 | sed -e s/--$*//g | sed -e s/Name//g`
else
	FOUND_VMS="review.opencontrail.org
fi

VM_TO_CP=`echo $FOUND_VMS | sed -e s%opencontrail\.org%%`

for j in $FOUND_VMS
do
	virsh --connect qemu:///system suspend $j
	PAUSED_VMS=`virsh --connect qemu:///system list | grep paused | wc -l`
	echo $PAUSED_VMS | tee -a /tmp/logs
	if [ $PAUSED_VMS -ne 1 ]; then 
		echo "Something fishy, cannot continue backup... !!" | tee -a /tmp/logs
		echo "Exiting... !!" | tee -a /tmp/logs
		exit 1
	fi
	
	BACKUP_IMAGE=`echo $j | sed -e s%\.opencontrail\.org%%`

	cp -v /var/lib/libvirt/images/$BACKUP_IMAGE*.opencontrail.org.vmdk $WORKDIR/"$BACKUP_IMAGE.opencontrail.org.vmdk-$date" | tee -a /tmp/logs 
	virsh --connect qemu:///system resume $j
	gzip $WORKDIR/"$BACKUP_IMAGE.opencontrail.org.vmdk-$date"
done
echo "Done..." | tee -a /tmp/logs
virsh --connect qemu:///system list | tee -a /tmp/logs
