#!/sbin/busybox sh

# Original by dorimanx for ExTweaks
# Modified by UpInTheAir and neobuddy89

BB=/sbin/busybox;
P=/res/synapse/files/cron_google;
GOOGLE=`cat $P`;
SYNAPSE_SD_DIR=/sdcard/Synapse;
SYNAPSE_CRON_DIR=$SYNAPSE_SD_DIR/crontab;

if [ "$($BB mount | grep rootfs | cut -c 26-27 | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /;
fi;

if [ $GOOGLE == 1 ]; then

	if [ "$($BB pidof com.google.android.gms | wc -l)" -eq "1" ]; then
		$BB kill $($BB pidof com.google.android.gms);
	fi;
	if [ "$($BB pidof com.google.android.gms.unstable | wc -l)" -eq "1" ]; then
		$BB kill $($BB pidof com.google.android.gms.unstable);
	fi;
	if [ "$($BB pidof com.google.android.gms.persistent | wc -l)" -eq "1" ]; then
		$BB kill $($BB pidof com.google.android.gms.persistent);
	fi;
	if [ "$($BB pidof com.google.android.gms.wearable | wc -l)" -eq "1" ]; then
		$BB kill $($BB pidof com.google.android.gms.wearable);
	fi;

	date +%R-%F > $SYNAPSE_CRON_DIR/cron-ram-release;
	echo " Google RAM released" >> $SYNAPSE_CRON_DIR/cron-ram-release;

elif [ $GOOGLE == 0 ]; then

	date +%R-%F > $SYNAPSE_CRON_DIR/cron-ram-release;
	echo " Google RAM Release is disabled" >> $SYNAPSE_CRON_DIR/cron-ram-release;
fi;

$BB mount -t rootfs -o remount,ro rootfs;
