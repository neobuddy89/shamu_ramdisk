#!/sbin/busybox sh

# Created By Dorimanx and Dairinin
# Modified by UpInTheAir and neobuddy89

SYNAPSE_SD_DIR=/sdcard/Synapse;
SYNAPSE_CRON_DIR=$SYNAPSE_SD_DIR/crontab;

BB=/sbin/busybox;

ROOTFS_MOUNT=$(mount | grep rootfs | cut -c26-27 | grep -c rw)
if [ "$ROOTFS_MOUNT" -eq "0" ]; then
	$BB mount -o remount,rw /;
fi;

if [ ! -e $SYNAPSE_CRON_DIR/ ]; then
	$BB mkdir $SYNAPSE_CRON_DIR/;
fi;

$BB cp -a /res/crontab_service/cron-root $SYNAPSE_CRON_DIR/root;
chown 0:0 $SYNAPSE_CRON_DIR/root;
chmod 777 $SYNAPSE_CRON_DIR/root;
if [ ! -d /var/spool/cron/crontabs ]; then
	mkdir -p /var/spool/cron/crontabs/;
fi;
$BB cp -a $SYNAPSE_CRON_DIR/root /var/spool/cron/crontabs/;

chown 0:0 /var/spool/cron/crontabs/*;
chmod 777 /var/spool/cron/crontabs/*;

# Check device local timezone & set for cron tasks
timezone=$(date +%z);
if [ "$timezone" == "+1400" ]; then
	TZ=UCT-14
elif [ "$timezone" == "+1300" ]; then
	TZ=UCT-13
elif [ "$timezone" == "+1245" ]; then
	TZ=CIST-12:45CIDT
elif [ "$timezone" == "+1200" ]; then
	TZ=NZST-12NZDT
elif [ "$timezone" == "+1100" ]; then
	TZ=UCT-11
elif [ "$timezone" == "+1030" ]; then
	TZ=LHT-10:30LHDT
elif [ "$timezone" == "+1000" ]; then
	TZ=UCT-10
elif [ "$timezone" == "+0930" ]; then
	TZ=UCT-9:30
elif [ "$timezone" == "+0900" ]; then
	TZ=UCT-9
elif [ "$timezone" == "+0830" ]; then
	TZ=KST
elif [ "$timezone" == "+0800" ]; then
	TZ=UCT-8
elif [ "$timezone" == "+0700" ]; then
	TZ=UCT-7
elif [ "$timezone" == "+0630" ]; then
	TZ=UCT-6:30
elif [ "$timezone" == "+0600" ]; then
	TZ=UCT-6
elif [ "$timezone" == "+0545" ]; then
	TZ=UCT-5:45
elif [ "$timezone" == "+0530" ]; then
	TZ=UCT-5:30
elif [ "$timezone" == "+0500" ]; then
	TZ=UCT-5
elif [ "$timezone" == "+0430" ]; then
	TZ=UCT-4:30
elif [ "$timezone" == "+0400" ]; then
	TZ=UCT-4
elif [ "$timezone" == "+0330" ]; then
	TZ=UCT-3:30
elif [ "$timezone" == "+0300" ]; then
	TZ=UCT-3
elif [ "$timezone" == "+0200" ]; then
	TZ=UCT-2
elif [ "$timezone" == "+0100" ]; then
	TZ=UCT-1
elif [ "$timezone" == "+0000" ]; then
	TZ=UCT
elif [ "$timezone" == "-0100" ]; then
	TZ=UCT1
elif [ "$timezone" == "-0200" ]; then
	TZ=UCT2
elif [ "$timezone" == "-0300" ]; then
	TZ=UCT3
elif [ "$timezone" == "-0330" ]; then
	TZ=NST3:30NDT
elif [ "$timezone" == "-0400" ]; then
	TZ=UCT4
elif [ "$timezone" == "-0430" ]; then
	TZ=UCT4:30
elif [ "$timezone" == "-0500" ]; then
	TZ=UCT5
elif [ "$timezone" == "-0600" ]; then
	TZ=UCT6
elif [ "$timezone" == "-0700" ]; then
	TZ=UCT7
elif [ "$timezone" == "-0800" ]; then
	TZ=UCT8
elif [ "$timezone" == "-0900" ]; then
	TZ=UCT9
elif [ "$timezone" == "-0930" ]; then
	TZ=UCT9:30
elif [ "$timezone" == "-1000" ]; then
	TZ=UCT10
elif [ "$timezone" == "-1100" ]; then
	TZ=UCT11
elif [ "$timezone" == "-1200" ]; then
	TZ=UCT12
else
	TZ=UCT
fi;

export TZ

#Set Permissions to scripts
chown 0:0 $SYNAPSE_CRON_DIR/cron-scripts/*;
chmod 777 $SYNAPSE_CRON_DIR/cron-scripts/*;

# use /var/spool/cron/crontabs/ call the crontab file "root"
if [ "$(pidof crond | wc -l)" -eq "0" ]; then
	$BB nohup /sbin/crond -c /var/spool/cron/crontabs/ > $SYNAPSE_CRON_DIR/cron.txt &
	sleep 1;
	PIDOFCRON=$(pidof crond);
	echo "-900" > /proc/"$PIDOFCRON"/oom_score_adj;
fi;

$BB mount -t rootfs -o remount,ro rootfs;
