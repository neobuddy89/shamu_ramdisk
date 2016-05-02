#!/sbin/busybox sh

# Mount root as RW to apply tweaks and settings
mount -o remount,rw /;
mount -o rw,remount /system

# Cleanup conflicts
#if [ -e /system/etc/sysctl.conf ]; then
#	mv /system/etc/sysctl.conf /system/etc/sysctl.conf-bak;
#fi;
rm -f /system/etc/init.d/N4UKM;
rm -f /system/etc/init.d/UKM;
rm -f /system/etc/init.d/UKM_WAKE;
rm -f /system/xbin/uci;
rm -rf /data/UKM;
rm -rf /data/data/leankernel;
if [ -e /system/xbin/zip ]; then
	rm -f /sbin/zip;
fi;

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
#echo "1536,2048,4096,16384,28672,32768" > /sys/module/lowmemorykiller/parameters/minfree
#echo 32 > /sys/module/lowmemorykiller/parameters/cost

# Disable kcal control and calibrate display for shamu
echo 0 > /sys/devices/platform/kcal_ctrl.0/kcal_enable
echo "250 250 255" > /sys/devices/platform/kcal_ctrl.0/kcal
echo 243 > /sys/devices/platform/kcal_ctrl.0/kcal_sat
echo 1515 > /sys/devices/platform/kcal_ctrl.0/kcal_hue
echo 250 > /sys/devices/platform/kcal_ctrl.0/kcal_val

# Install Busybox
/sbin/busybox --install -s /sbin

# Allow untrusted apps to read from debugfs
if [ -e /system/lib/libsupol.so ]; then
/system/xbin/supolicy --live \
	"allow untrusted_app debugfs file { open read getattr }" \
	"allow untrusted_app sysfs_lowmemorykiller file { open read getattr }" \
	"allow untrusted_app persist_file dir { open read getattr }" \
	"allow debuggerd gpu_device chr_file { open read getattr }" \
	"allow netd netd capability fsetid" \
	"allow netd { hostapd dnsmasq } process fork" \
	"allow { system_app shell } dalvikcache_data_file file write" \
	"allow { zygote mediaserver bootanim appdomain }  theme_data_file dir { search r_file_perms r_dir_perms }" \
	"allow { zygote mediaserver bootanim appdomain }  theme_data_file file { r_file_perms r_dir_perms }" \
	"allow system_server { rootfs resourcecache_data_file } dir { open read write getattr add_name setattr create remove_name rmdir unlink link }" \
	"allow system_server resourcecache_data_file file { open read write getattr add_name setattr create remove_name unlink link }" \
	"allow system_server dex2oat_exec file rx_file_perms" \
	"allow mediaserver mediaserver_tmpfs file execute" \
	"allow drmserver theme_data_file file r_file_perms" \
	"allow zygote system_file file write" \
	"allow atfwd property_socket sock_file write" \
	"allow debuggerd app_data_file dir search" \
	"allow sensors diag_device chr_file { read write open ioctl }" \
	"allow sensors sensors capability net_raw" \
	"allow init kernel security setenforce" \
	"allow netmgrd netmgrd netlink_xfrm_socket nlmsg_write" \
	"allow netmgrd netmgrd socket { read write open ioctl }"
fi;

# Copy Cron files
cp -af /res/crontab/ /sdcard/Synapse
if [ ! -e /sdcard/Synapse/crontab/custom_jobs ]; then
	touch /sdcard/Synapse/crontab/custom_jobs;
	chmod 777 /sdcard/Synapse/crontab/custom_jobs;
fi;

ln -s /res/synapse/uci /sbin/uci
cd /
/sbin/uci

# Init.d Support
/sbin/busybox run-parts /system/etc/init.d

if [ -e /data/.selinux_enabled ]; then
	setenforce 1
fi;

exit;
