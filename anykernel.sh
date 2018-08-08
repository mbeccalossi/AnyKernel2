# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=OpenEngine by kylothow @ xda-developers
do.devicecheck=1
do.cleanupmodules=1
do.modules=1
do.cleanup=1
do.cleanuponabort=0
device.name1=cheeseburger
device.name2=OnePlus5
device.name3=dumpling
device.name4=OnePlus5T
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
find $ramdisk -type f -exec chmod 644 {} \;
chown -R root:root $ramdisk/*;


## AnyKernel install
dump_boot;

# begin ramdisk changes

rm -f $ramdisk/init.oem.early_boot.sh;
rm -f $ramdisk/init.oem.engineermode.sh;

# init.rc
insert_line init.rc "init.oek.rc" before "import /init.environ.rc" "import /init.oek.rc";
remove_section init.rc "service flash_recovery" "";

# init.oem.rc
remove_section init.oem.rc "service OPNetlinkService" ""
remove_section init.oem.rc "service wifisocket" ""
remove_section init.oem.rc "service oemsysd" ""
remove_section init.oem.rc "service oem_audio_device" "oneshot"
remove_section init.oem.rc "service atrace" "seclabel"
remove_section init.oem.rc "service sniffer_set" ""
remove_section init.oem.rc "service sniffer_start" ""
remove_section init.oem.rc "service sniffer_stop" "seclabel"
remove_section init.oem.rc "service tcpdump-service" ""

# init.oem.debug.rc
remove_section init.oem.debug.rc "service oemlogkit" ""
remove_section init.oem.debug.rc "service dumpstate_log" ""
remove_section init.oem.debug.rc "service oemasserttip" ""

# end ramdisk changes

write_boot;

## end install

