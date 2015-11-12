#!/sbin/busybox sh

BB=/sbin/busybox;

# Mount root as RW to apply tweaks and settings
$BB mount -o remount,rw /;
$BB mount -o rw,remount /system

# Cleanup conflicts
if [ -e /system/etc/sysctl.conf ]; then
	$BB mv /system/etc/sysctl.conf /system/etc/sysctl.conf-bak;
fi;
$BB rm -f /system/etc/init.d/N4UKM;
$BB rm -f /system/etc/init.d/UKM;
$BB rm -f /system/etc/init.d/UKM_WAKE;
$BB rm -f /system/xbin/uci;
$BB rm -rf /data/UKM;
$BB rm -rf /data/data/leankernel;
if [ -e /system/xbin/zip ]; then
	$BB rm -f /sbin/zip;
fi;

# Make tmp folder
$BB mkdir /tmp;

# Give permissions to execute
$BB chown -R root:system /tmp/;
$BB chmod -R 777 /tmp/;
$BB chmod -R 777 /res/;
$BB chmod 6755 /res/synapse/actions/*;
$BB chmod 6755 /sbin/*;
$BB chmod 6755 /system/xbin/*;
$BB echo "Boot initiated on $(date)" > /tmp/bootcheck;

# Tune LMK with values we love
#$BB echo "1536,2048,4096,16384,28672,32768" > /sys/module/lowmemorykiller/parameters/minfree
#$BB echo 32 > /sys/module/lowmemorykiller/parameters/cost

# Adaptive LMK
$BB echo 1 > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
$BB echo 53059 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min
$BB echo 1 > /sys/module/process_reclaim/parameters/enable_process_reclaim
$BB echo 100 > /sys/module/process_reclaim/parameters/pressure_max
$BB echo 200 > /proc/sys/vm/dirty_expire_centisecs
$BB echo 20 > /proc/sys/vm/dirty_background_ratio
$BB echo 40 > /proc/sys/vm/dirty_ratio
$BB echo 0 > /proc/sys/vm/swappiness

# Calibrate display
$BB echo "250 250 255" > /sys/devices/platform/kcal_ctrl.0/kcal
$BB echo 243 > /sys/devices/platform/kcal_ctrl.0/kcal_sat
$BB echo 1515 > /sys/devices/platform/kcal_ctrl.0/kcal_hue
$BB echo 250 > /sys/devices/platform/kcal_ctrl.0/kcal_val

# Tweak VM
$BB echo 200 > /proc/sys/vm/dirty_expire_centisecs
$BB echo 20 > /proc/sys/vm/dirty_background_ratio
$BB echo 40 > /proc/sys/vm/dirty_ratio
$BB echo 0 > /proc/sys/vm/swappiness

# Install Busybox
$BB --install -s /sbin

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

$BB ln -s /res/synapse/uci /sbin/uci
/sbin/uci

# Init.d Support
/sbin/busybox run-parts /system/etc/init.d

# Google Services battery drain fixer by Alcolawl@xda
pm enable com.google.android.gms/.update.SystemUpdateActivity
pm enable com.google.android.gms/.update.SystemUpdateService
pm enable com.google.android.gms/.update.SystemUpdateService$ActiveReceiver
pm enable com.google.android.gms/.update.SystemUpdateService$Receiver
pm enable com.google.android.gms/.update.SystemUpdateService$SecretCodeReceiver
pm enable com.google.android.gsf/.update.SystemUpdateActivity
pm enable com.google.android.gsf/.update.SystemUpdatePanoActivity
pm enable com.google.android.gsf/.update.SystemUpdateService
pm enable com.google.android.gsf/.update.SystemUpdateService$Receiver
pm enable com.google.android.gsf/.update.SystemUpdateService$SecretCodeReceiver

if [ -e /data/.selinux_enabled ]; then
	setenforce 1
fi;

exit;
