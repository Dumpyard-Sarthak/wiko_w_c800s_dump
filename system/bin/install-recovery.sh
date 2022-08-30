#!/system/bin/sh
if ! applypatch -c EMMC:/dev/block/bootdevice/by-name/recovery:14648620:3b5275269d44ed7a979aa06d338e45761c67aeac; then
  applypatch -b /system/etc/recovery-resource.dat EMMC:/dev/block/bootdevice/by-name/boot:12383528:7779ca5230564ff6d8714964daf5f41bcf8a6909 EMMC:/dev/block/bootdevice/by-name/recovery 3b5275269d44ed7a979aa06d338e45761c67aeac 14648620 7779ca5230564ff6d8714964daf5f41bcf8a6909:/system/recovery-from-boot.p && log -t recovery "Installing new recovery image: succeeded" || log -t recovery "Installing new recovery image: failed"
else
  log -t recovery "Recovery image already installed"
fi
