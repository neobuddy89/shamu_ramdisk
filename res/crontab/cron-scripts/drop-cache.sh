#!/sbin/busybox sh

# Drop cache script
# Original by dorimanx for ExTweaks
# Modified by UpInTheAir and neobuddy89

BB=/sbin/busybox;
P=/res/synapse/files/cron_drop_cache;
DROP_CACHE=`cat $P`;
SYNAPSE_SD_DIR=/sdcard/Synapse;
SYNAPSE_CRON_DIR=$SYNAPSE_SD_DIR/crontab;

if [ "$($BB mount | grep rootfs | cut -c 26-27 | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /;
fi;

if [ $DROP_CACHE == 1 ]; then

	while read TYPE MEM KB; do
		if [ "$TYPE" = "MemTotal:" ]; then
			TOTAL=$((MEM / 1024));
		elif [ "$TYPE" = "MemFree:" ]; then
			CACHED=$((MEM / 1024));
		elif [ "$TYPE" = "Cached:" ]; then
			FREE=$((MEM / 1024));
		fi;
 	 done < /proc/meminfo;
		
  	FREE=$(($FREE + $CACHED));
	MEM_USED_CALC=$(($FREE*100/$TOTAL));

	# do clean cache only if cache uses 50% of free memory.
	if [ "$MEM_USED_CALC" -gt "50" ]; then

		# wait till CPU is idle.
		while [ ! `cat /proc/loadavg | cut -c1-4` -lt "3.50" ]; do
			echo "Waiting For CPU to cool down";
			sleep 30;
		done;

		sync;
		sysctl -w vm.drop_caches=3;
		sync;

		date +%R-%F > $SYNAPSE_CRON_DIR/cron-clear-ram-cache;
		echo " Cache above 50%! Cleaned RAM Cache" >> $SYNAPSE_CRON_DIR/cron-clear-ram-cache;

	elif [ "$MEM_USED_CALC" -lt "50" ]; then

		date +%R-%F > $SYNAPSE_CRON_DIR/cron-clear-ram-cache;
		echo " Cache below 50%! Cleaning RAM Cache aborted" >> $SYNAPSE_CRON_DIR/cron-clear-ram-cache;
	fi;

elif [ $DROP_CACHE == 0 ]; then

	date +%R-%F > $SYNAPSE_CRON_DIR/cron-clear-ram-cache;
	echo " Clean RAM Cache is disabled" >> $SYNAPSE_CRON_DIR/cron-clear-ram-cache;
fi;

$BB mount -t rootfs -o remount,ro rootfs;
