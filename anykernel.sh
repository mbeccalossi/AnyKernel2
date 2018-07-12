# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=Flash Kernel for the OnePlus 5/T by @nathanchance
do.devicecheck=1
do.cleanupmodules=1
do.modules=1
do.cleanup=1
do.cleanuponabort=0
device.name1=OnePlus5
device.name2=OnePlus5T
device.name3=cheeseburger
device.name4=dumpling
device.name5=
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;


## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
chmod -R 750 $ramdisk/*;
chmod 644 $ramdisk/WCNSS_qcom_cfg.ini;
chmod 644 $ramdisk/modules/*;
chown -R root:root $ramdisk/*;


# Print message and exit
die() {
  ui_print " "; ui_print "$*";
  exit 1;
}


# Alert of unsupported Android version
android_ver=$(file_getprop /system/build.prop "ro.build.version.release");
case "$android_ver" in
  "8.0.0"|"8.1.0") support_status="supported";;
  *) support_status="unsupported";;
esac;
ui_print " ";
ui_print "Running Android $android_ver..."
ui_print "This kernel is $support_status for this version!";


# Select the correct image to flash
userflavor="$(file_getprop /system/build.prop "ro.build.user"):$(file_getprop /system/build.prop "ro.build.flavor")";
case "$userflavor" in
  "OnePlus:OnePlus5-user"|"OnePlus:OnePlus5T-user")
    os="oos";
    os_string="OxygenOS";;
  *)
    os="custom";
    os_string="a custom ROM";;
esac;
ui_print " ";
ui_print "You are on $os_string!";
if [ -f /tmp/anykernel/kernels/$os/Image.gz-dtb ]; then
  mv /tmp/anykernel/kernels/$os/Image.gz-dtb /tmp/anykernel/Image.gz-dtb;
  mkdir -p /tmp/anykernel/modules/system/lib/modules;
  mv /tmp/anykernel/kernels/$os/wlan.ko /tmp/anykernel/modules/system/lib/modules/wlan.ko;
else
  die "There is no kernel for your OS in this zip! Aborting...";
fi;


## AnyKernel install
dump_boot;

# begin ramdisk changes

# Set the default background app limit to 60
insert_line default.prop "ro.sys.fw.bg_apps_limit=60" before "ro.secure=1" "ro.sys.fw.bg_apps_limit=60";

# Import init.flash.rc file
insert_line init.rc "init.flash.rc" after "import /init.usb.rc" "import /init.flash.rc";

# If on OOS, we need to do some additional cleaning
if [ "$os" == "oos" ]; then
  # Remove recovery service so that TWRP isn't overwritten
  remove_section init.rc "service flash_recovery" ""

  # Remove suspicious OnePlus services
  remove_section init.oem.rc "service OPNetlinkService" ""
  remove_section init.oem.rc "service wifisocket" ""
  remove_section init.oem.rc "service oemsysd" ""
  remove_section init.oem.rc "service oem_audio_device" "oneshot"
  remove_section init.oem.rc "service atrace" "seclabel"
  remove_section init.oem.rc "service sniffer_set" ""
  remove_section init.oem.rc "service sniffer_start" ""
  remove_section init.oem.rc "service sniffer_stop" "seclabel"
  remove_section init.oem.rc "service tcpdump-service" ""
  remove_section init.oem.debug.rc "service oemlogkit" ""
  remove_section init.oem.debug.rc "service dumpstate_log" ""
  remove_section init.oem.debug.rc "service oemasserttip" ""
fi;

# end ramdisk changes

write_boot;


## end install

