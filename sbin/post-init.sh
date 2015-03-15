#!/sbin/busybox sh

# Mount root as RW to apply tweaks and settings
mount -o remount,rw /;
mount -o rw,remount /system

# Cleanup conflicts
if [ -e /system/etc/sysctl.conf ]; then
	mv /system/etc/sysctl.conf /system/etc/sysctl.conf-bak;
fi;
rm -f /system/etc/init.d/N4UKM;
rm -f /system/etc/init.d/UKM;
rm -f /system/etc/init.d/UKM_WAKE;
rm -f /system/xbin/uci;
rm -rf /data/UKM;

# Make tmp folder
mkdir /tmp;

# Give permissions to execute
chown -R root:system /tmp/;
chmod -R 777 /tmp/;
chmod -R 777 /res/;
chmod 6755 /res/synapse/actions/*;
chmod 6755 /sbin/*;
chmod 6755 /system/xbin/*;
echo "Boot initiated on $(date)" > /tmp/bootcheck;

# Tune LMK with values we love
echo "1536,2048,4096,16384,28672,32768" > /sys/module/lowmemorykiller/parameters/minfree
echo 32 > /sys/module/lowmemorykiller/parameters/cost

# Calibrate display
echo "250 250 255" > /sys/devices/platform/kcal_ctrl.0/kcal
echo 243 > /sys/devices/platform/kcal_ctrl.0/kcal_sat
echo 1515 > /sys/devices/platform/kcal_ctrl.0/kcal_hue
echo 250 > /sys/devices/platform/kcal_ctrl.0/kcal_val

# Install Busybox
/sbin/busybox --install -s /sbin

ln -s /res/synapse/uci /sbin/uci
/sbin/uci

if [ ! -e /data/.selinux_disabled ]; then
	setenforce 1
fi;

exit;
