#!/sbin/busybox sh

# FSTrim script
# created by UpInTheAir
# modified by neobuddy89

BB=/sbin/busybox;
P=/res/synapse/files/cron_fstrim;
FSTRIM=`cat $P`;
SYNAPSE_SD_DIR=/sdcard/Synapse;
SYNAPSE_CRON_DIR=$SYNAPSE_SD_DIR/crontab;

if [ "$($BB mount | grep rootfs | cut -c 26-27 | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /;
fi;
if [ "$($BB mount | grep system | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /system;
fi;

if [ $FSTRIM == 1 ]; then

	# wait till CPU is idle.
	while [ ! `cat /proc/loadavg | cut -c1-4` -lt "3.50" ]; do
		echo "Waiting For CPU to cool down";
		sleep 30;
	done;

	/sbin/fstrim -v /system
	/sbin/fstrim -v /data
	/sbin/fstrim -v /cache

	$BB sync

	date +%R-%F > $SYNAPSE_CRON_DIR/cron-fstrim;
	echo " File System trimmed" >> $SYNAPSE_CRON_DIR/cron-fstrim;

elif [ $FSTRIM == 0 ]; then

	date +%R-%F > $SYNAPSE_CRON_DIR/cron-fstrim;
	echo " File System Trim is disabled" >> $SYNAPSE_CRON_DIR/cron-fstrim;
fi;

$BB mount -t rootfs -o remount,ro rootfs;
$BB mount -o remount,ro /system;
