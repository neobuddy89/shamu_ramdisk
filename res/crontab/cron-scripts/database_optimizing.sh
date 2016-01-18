#!/sbin/busybox sh

# Optimize Databases script
# Original by dorimanx for ExTweaks
# Modified by UpInTheAir and neobuddy89

BB=/sbin/busybox;
P=/res/synapse/files/cron_sqlite;
SQLITE=`cat $P`;
SYNAPSE_SD_DIR=/sdcard/Synapse;
SYNAPSE_CRON_DIR=$SYNAPSE_SD_DIR/crontab;

if [ "$($BB mount | grep rootfs | cut -c 26-27 | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /;
fi;

if [ $SQLITE == 1 ]; then

	# wait till CPU is idle.
	while [ ! `cat /proc/loadavg | cut -c1-4` -lt "3.50" ]; do
		echo "Waiting For CPU to cool down";
		sleep 30;
	done;

	for i in $(find /data -iname "*.db"); do
		sbin/sqlite3 $i 'VACUUM;' 2> /dev/null;
		sbin/sqlite3 $i 'REINDEX;' 2> /dev/null;
	done;

	for i in $(find /sdcard -iname "*.db"); do
		sbin/sqlite3 $i 'VACUUM;' 2> /dev/null;
		sbin/sqlite3 $i 'REINDEX;' 2> /dev/null;
	done;
	sync;

	date +%R-%F > $SYNAPSE_CRON_DIR/cron-db-optimizing;
	echo " DB Optimized" >> $SYNAPSE_CRON_DIR/cron-db-optimizing;

elif [ $SQLITE == 0 ]; then

	date +%R-%F > $SYNAPSE_CRON_DIR/cron-db-optimizing;
	echo " DB Optimization is disabled" >> $SYNAPSE_CRON_DIR/cron-db-optimizing;
fi;

$BB mount -t rootfs -o remount,ro rootfs;
