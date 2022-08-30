#!/system/bin/sh

#########################################################################
# File Name: logd-catch.sh
# Author: Shaobin
# mail: shaobin.zhang@tinno.com
# Created Time: Wed Apr 22 16:26:44 2015
#########################################################################

#/system/bin/sleep 30
WAIT_BOOTCOMPLETED=`/system/bin/getprop sys.boot_completed`
if test "$WAIT_BOOTCOMPLETED" = ""
then
/system/bin/sleep 15
fi

#echo -n "file msm8x16-wcd.c +p" > /sys/kernel/debug/dynamic_debug/control
#echo -n "file wcd-mbhc-v2.c +p" > /sys/kernel/debug/dynamic_debug/control
#echo -n "file msm8952.c +p" > /sys/kernel/debug/dynamic_debug/control

LOG_PATH=/storage/emulated/0/Logs
LOG_DATA_PATH=/data/tinnolog
ENABLE_DATALOG=`/system/bin/getprop persist.tinno.log.save`
DATE_INFO=`date  "+%Y_%m%d_%H%M"`
LOG_NUM_MAX=`/system/bin/getprop persist.tinno.log.num`
LOG_CHECK_FLAG=`df -h data|sed -n '$p'|cut -c 38`

if test "$LOG_CHECK_FLAG" = "M"
then
	/system/bin/log TinnoLog "LOG_CHECK_FLAG= $LOG_CHECK_FLAG";
	/system/bin/setprop persist.tinno.logd-catch.enable "false";
	/system/bin/setprop persist.tinno.logd-catch.tcp "false";
fi

#TINNO:Jaky
while true
do 
	mkdir -p $LOG_PATH
	touch /storage/emulated/0/Logs/test_aplog_file; 
	if [ -f "/storage/emulated/0/Logs/test_aplog_file" ]; then 
		break; 
	fi; 
	sleep 5; 
done

pre_log()
{
if test "$ENABLE_DATALOG" = "data"
then
  mkdir -p $LOG_DATA_PATH/AP_Logs
  mkdir -p $LOG_DATA_PATH/AP_Logs/APLogs_$DATE_INFO
  mkdir -p $LOG_DATA_PATH/BugreportLogs
else
  mkdir -p $LOG_PATH/AP_Logs
  #mkdir -p $LOG_PATH/logs-back
  mkdir -p $LOG_PATH/BugreportLogs
  mkdir -p /data/BugreportLogs
  #chown system.system $LOG_PATH/AP_Logs
  #chown system.system $LOG_PATH/logs-back
  #chown system.system $LOG_PATH/BugreportLogs
  #chown system.system /data/BugreportLogs
  #back-up last logs
  #/system/bin/mv $LOG_PATH/AP_Logs/* $LOG_PATH/logs-back
  #catch logcat && radio_log && kernel_log into $LOG_PATH
  mkdir -p $LOG_PATH/AP_Logs/APLogs_$DATE_INFO
  /system/bin/cp /system/build.prop $LOG_PATH/AP_Logs/build.prop
  /system/bin/getprop  > $LOG_PATH/AP_Logs/getprop.prop
fi
}

trace_b()
{
	#backup trace log
	mkdir -p $LOG_PATH/Trace/anr
	mkdir -p $LOG_PATH/Trace/dropbox
	mkdir -p $LOG_PATH/Trace/tombstones
	mkdir -p $LOG_PATH/Trace/PS
	mkdir -p $LOG_PATH/Trace/recovery
	/system/bin/cp -r /data/anr $LOG_PATH/Trace
	/system/bin/cp -r /data/system/dropbox $LOG_PATH/Trace
	/system/bin/cp -r /data/tombstones $LOG_PATH/Trace
	/system/bin/cp -r /cache/recovery $LOG_PATH/Trace
}


OPT=$1

if test "$OPT" = "trace"
then
trace_b;
elif test "$OPT" = "stop"
then
PID=`/system/bin/getprop persist.tinno.logd-catch.tcppid`
kill -2 $PID
elif test "$OPT" = "battery"
then
/system/bin/dumpsys batterystats > /data/tinnolog/batterystats.txt
/system/bin/cp -r /data/tinnolog/batterystats.txt $LOG_PATH/AP_Logs/
else
pre_log;
fi


if test "$ENABLE_DATALOG" = "data"
then
	if test "$OPT" = "all"
	then
	/system/bin/cp -r /sys/fs/pstore/console-ramoops $LOG_DATA_PATH/AP_Logs/APLogs_$DATE_INFO/lastkmesg.txt &
	/system/bin/logcat -v threadtime -b all -n $LOG_NUM_MAX -r 100000 -f $LOG_DATA_PATH/AP_Logs/APLogs_$DATE_INFO/logcat_$DATE_INFO.log &
	/system/bin/logcat -v threadtime -b events -n $LOG_NUM_MAX -r 100000 -f $LOG_DATA_PATH/AP_Logs/APLogs_$DATE_INFO/logcat_events_$DATE_INFO.log 
	elif test "$OPT" = "radio"
	then
	/system/bin/logcat -v threadtime -b radio -n $LOG_NUM_MAX -r 100000 -f $LOG_DATA_PATH/AP_Logs/APLogs_$DATE_INFO/logcat_radio_$DATE_INFO.log 
        elif test "$OPT" = "lklog"
        then
        /system/bin/cat /proc/lklog > $LOG_DATA_PATH/AP_Logs/APLogs_$DATE_INFO/lklog_$DATE_INFO.log
	elif test "$OPT" = "dmesg"
	then
	#/system/bin/dmesg -r 100m -f $LOG_PATH/AP_Logs/APLogs_$DATE_INFO/dmesg_$DATE_INFO.log
	/system/bin/logcat -v threadtime -b kernel -n $LOG_NUM_MAX -r 100000 -f $LOG_DATA_PATH/AP_Logs/APLogs_$DATE_INFO/dmesg_$DATE_INFO.log
	#/system/bin/dmesg -x -f $LOG_DATA_PATH/AP_Logs/APLogs_$DATE_INFO/dmesg_$DATE_INFO.log
	#/system/bin/logwrapper /system/bin/dmesg -r 100m -f $LOG_PATH/AP_Logs/APLogs_$DATE_INFO/dmesg_$DATE_INFO.log -DEBUG
	elif test "$OPT" = "tcp"
	then
	tcpdump -i any -s 0 -l -w $LOG_DATA_PATH/AP_Logs/APLogs_$DATE_INFO/tcpdump_$DATE_INFO.pcap 'not ether proto 0xda1a' &
	/system/bin/setprop persist.tinno.logd-catch.tcppid $!
	wait $!
	elif test "$OPT" = "bgr"
	then
	/system/bin/bugreport > $LOG_DATA_PATH/BugreportLogs/bugreport_$DATE_INFO.log
	fi
else
	if test "$OPT" = "all"
	then
	/system/bin/cp -r /sys/fs/pstore/console-ramoops $LOG_PATH/AP_Logs/APLogs_$DATE_INFO/lastkmesg.txt &
	/system/bin/logcat -v threadtime -b all -n $LOG_NUM_MAX -r 100000 -f $LOG_PATH/AP_Logs/APLogs_$DATE_INFO/logcat_$DATE_INFO.log &
	/system/bin/logcat -v threadtime -b events -n $LOG_NUM_MAX -r 100000 -f $LOG_PATH/AP_Logs/APLogs_$DATE_INFO/logcat_events_$DATE_INFO.log 
	elif test "$OPT" = "radio"
	then
	/system/bin/logcat -v threadtime -b radio -n $LOG_NUM_MAX -r 100000 -f $LOG_PATH/AP_Logs/APLogs_$DATE_INFO/logcat_radio_$DATE_INFO.log
        elif test "$OPT" = "lklog"
        then
        /system/bin/cat /proc/lklog > $LOG_PATH/AP_Logs/APLogs_$DATE_INFO/lklog_$DATE_INFO.log
	elif test "$OPT" = "dmesg"
	then
	#/system/bin/dmesg -r 100m -f $LOG_PATH/AP_Logs/APLogs_$DATE_INFO/dmesg_$DATE_INFO.log
	/system/bin/logcat -v threadtime -b kernel -n $LOG_NUM_MAX -r 100000 -f $LOG_PATH/AP_Logs/APLogs_$DATE_INFO/dmesg_$DATE_INFO.log
	#/system/bin/dmesg -x -f $LOG_PATH/AP_Logs/APLogs_$DATE_INFO/dmesg_$DATE_INFO.log
	#/system/bin/logwrapper /system/bin/dmesg -r 100m -f $LOG_PATH/AP_Logs/APLogs_$DATE_INFO/dmesg_$DATE_INFO.log -DEBUG
	elif test "$OPT" = "tcp"
	then
	tcpdump -i any -s 0 -l -w $LOG_PATH/AP_Logs/APLogs_$DATE_INFO/tcpdump_$DATE_INFO.pcap 'not ether proto 0xda1a' &
	/system/bin/setprop persist.tinno.logd-catch.tcppid $!
	wait $!
	elif test "$OPT" = "bgr"
	then
	/system/bin/bugreport > $LOG_PATH/BugreportLogs/bugreport_$DATE_INFO.log
	fi
fi
