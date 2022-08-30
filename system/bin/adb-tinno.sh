#!/system/bin/sh
OPT=$1

mkdir -p /data/security/current
/system/bin/cp -f /seapp_contexts /data/security/current/seapp_contexts
/system/bin/cp -f /file_contexts.bin /data/security/current/file_contexts.bin
/system/bin/cp -f /property_contexts /data/security/current/property_contexts
/system/bin/cp -f /service_contexts /data/security/current/service_contexts
/system/bin/cp -f /sepolicy_tinno /data/security/current/sepolicy
/system/bin/cp -f /selinux_version /data/security/current/selinux_version

if test "$OPT" = "not"
then
echo -n "Tinno not root" > /data/security/current/selinux_version
else
echo 1 > /d/selinux_avc_log
fi
/system/bin/setprop persist.tinno.debug.adb "1"