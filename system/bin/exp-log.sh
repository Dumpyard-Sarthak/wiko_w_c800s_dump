#!/system/bin/sh

#########################################################################
# File Name: exp-log.sh
# Author: sunny.sang
# Created Time: 
#########################################################################

TAG=`/system/bin/getprop persist.tinno.excption.tag`
PID=`/system/bin/getprop persist.tinno.excption.pid`
TOMBSOMTE=`/system/bin/getprop persist.tinno.excption.tomb`

LOG_PATH=/storage/emulated/0/Logs/Tinno_exp/
NUM_INFO="0"
LOG_NUM_MAX=`/system/bin/getprop persist.tinno.log.num`
LOG_CHECK_FLAG=`df data|sed -n '$p'|cut -c 47`

if test "$LOG_CHECK_FLAG" = "M"
then
	/system/bin/log TinnoLog "tinno exp LOG_CHECK_FLAG= $LOG_CHECK_FLAG";
	exit
fi

while true
do 
	mkdir -p $LOG_PATH
	touch /storage/emulated/0/Logs/Tinno_exp/test_explog_file; 
	if [ -f "/storage/emulated/0/Logs/Tinno_exp/test_explog_file" ]; then 
		#rm /storage/emulated/0/Logs/Tinno_exp/test_explog_file;
		/system/bin/setprop persist.tinno.excption.tag "none";
		/system/bin/setprop persist.tinno.excption.tomb "none";
		/system/bin/setprop persist.tinno.excption.dump "false";
		break; 
	fi; 
	sleep 5; 
done

LOG_NUM=`ls /storage/emulated/0/Logs/Tinno_exp/ -l| grep "^d" | wc -l`

dump_logs()
{
	#dump logs to $LOG_PATH
	mkdir -p $LOG_PATH/EXP_0"$NUM_INFO"
	#mkdir -p /data/tinnoexp/
	/system/bin/mv  /data/tinnoexp/exp_main.txt $LOG_PATH/EXP_0"$NUM_INFO"/_exp_main_pid"$PID"_$TAG.txt
	/system/bin/cp  "$TOMBSOMTE" $LOG_PATH/EXP_0"$NUM_INFO"/_exp_detail_pid"$PID"_$TAG.txt
	#proc info
	/system/bin/cat /proc/$PID/cmdline > $LOG_PATH/EXP_0"$NUM_INFO"/PROCESS_CMDLINE
	/system/bin/cat /proc/$PID/environ > $LOG_PATH/EXP_0"$NUM_INFO"/PROCESS_ENVIRONMENT
	/system/bin/ls -al /proc/$PID/fd > $LOG_PATH/EXP_0"$NUM_INFO"/PROCESS_FILE_STATE
	/system/bin/cat /proc/$PID/maps > $LOG_PATH/EXP_0"$NUM_INFO"/PROCESS_MAPS
	/system/bin/cat /proc/$PID/oom_adj > $LOG_PATH/EXP_0"$NUM_INFO"/PROCESS_OOM_ADJ
	/system/bin/cat /proc/$PID/oom_score > $LOG_PATH/EXP_0"$NUM_INFO"/PROCESS_OOM_SCORE
	/system/bin/cat /proc/$PID/sched > $LOG_PATH/EXP_0"$NUM_INFO"/PROCESS_SCHED
	/system/bin/cat /proc/$PID/smaps > $LOG_PATH/EXP_0"$NUM_INFO"/PROCESS_SHOWMAP
	/system/bin/cat /proc/$PID/status > $LOG_PATH/EXP_0"$NUM_INFO"/PROCESS_STATE
	#dumpsys info
	/system/bin/dumpsys meminfo > /data/tinnoexp/DUMPSYS_MEMINFO
	/system/bin/dumpsys SurfaceFlinger > /data/tinnoexp/DUMPSYS_SURFACEFLINGER
	/system/bin/dumpsys input > /data/tinnoexp/DUMPSYS_INPUT
	/system/bin/dumpsys window > /data/tinnoexp/DUMPSYS_WINDOW
	/system/bin/dumpsys activity > /data/tinnoexp/DUMPSYS_ACTIVITY
	/system/bin/dumpsys dbinfo > /data/tinnoexp/DUMPSYS_DBINFO
	/system/bin/dumpsys TPS > /data/tinnoexp/DUMPSYS_TPS
	/system/bin/dumpsys TCS > /data/tinnoexp/DUMPSYS_TCS
	/system/bin/mv  /data/tinnoexp/DUMPSYS_* $LOG_PATH/EXP_0"$NUM_INFO"
	#logcat info
	/system/bin/logcat -b events -d -t 5000 -f $LOG_PATH/EXP_0"$NUM_INFO"/SYS_ANDROID_EVENT_LOG &
	/system/bin/logcat -b radio -d -t 5000 -f $LOG_PATH/EXP_0"$NUM_INFO"/SYS_ANDROID_RADIO_LOG &
	/system/bin/logcat -b kernel -d -t 5000 -f $LOG_PATH/EXP_0"$NUM_INFO"/SYS_ANDROID_KERNEL_LOG &
	/system/bin/logcat -b all -d -f $LOG_PATH/EXP_0"$NUM_INFO"/SYS_ANDROID_LOG &
	#system info
	/system/bin/cat /sys/class/leds/lcd-backlight/brightness > $LOG_PATH/EXP_0"$NUM_INFO"/SYS_BACKLIGHTS
	/system/bin/cat /etc/event-log-tags > $LOG_PATH/EXP_0"$NUM_INFO"/SYS_EVENT_LOG_TAGS
	#add binder info
	/system/bin/echo "------------BINDER FAILED TRANSACTION LOG:" > $LOG_PATH/EXP_0"$NUM_INFO"/SYS_BINDER_INFO
	/system/bin/cat /sys/kernel/debug/binder/failed_transaction_log >> $LOG_PATH/EXP_0"$NUM_INFO"/SYS_BINDER_INFO
	/system/bin/echo "------------BINDER TRANSACTION LOG:" >> $LOG_PATH/EXP_0"$NUM_INFO"/SYS_BINDER_INFO
	/system/bin/cat /sys/kernel/debug/binder/transaction_log >> $LOG_PATH/EXP_0"$NUM_INFO"/SYS_BINDER_INFO
	/system/bin/echo "------------BINDER TRANSACTIONS:" >> $LOG_PATH/EXP_0"$NUM_INFO"/SYS_BINDER_INFO
	/system/bin/cat /sys/kernel/debug/binder/transactions >> $LOG_PATH/EXP_0"$NUM_INFO"/SYS_BINDER_INFO
	/system/bin/echo "------------BINDER STATS:" >> $LOG_PATH/EXP_0"$NUM_INFO"/SYS_BINDER_INFO
	/system/bin/cat /sys/kernel/debug/binder/stats >> $LOG_PATH/EXP_0"$NUM_INFO"/SYS_BINDER_INFO
	/system/bin/echo "------------BINDER STATE:" >> $LOG_PATH/EXP_0"$NUM_INFO"/SYS_BINDER_INFO
	/system/bin/cat /sys/kernel/debug/binder/state >> $LOG_PATH/EXP_0"$NUM_INFO"/SYS_BINDER_INFO

	/system/bin/df > $LOG_PATH/EXP_0"$NUM_INFO"/SYS_FILE_SYSTEMS
	/system/bin/cat /sys/kernel/debug/ion/heaps/system > $LOG_PATH/EXP_0"$NUM_INFO"/SYS_ION_MM_HEAP
	/system/bin/cat /sys/kernel/debug/wakeup_sources > $LOG_PATH/EXP_0"$NUM_INFO"/SYS_KERNEL_WAKELOCKS
	/system/bin/mount > $LOG_PATH/EXP_0"$NUM_INFO"/SYS_MEMORY_INFO
	/system/bin/iptables -L > $LOG_PATH/EXP_0"$NUM_INFO"/SYS_NETWORK_STATE
	/system/bin/cat /data/system/packages.xml > $LOG_PATH/EXP_0"$NUM_INFO"/SYS_PACKAGE_SETTINGS
	/system/bin/ps -t -p -P > $LOG_PATH/EXP_0"$NUM_INFO"/SYS_PROCESSES_AND_THREADS
	/system/bin/getprop > $LOG_PATH/EXP_0"$NUM_INFO"/SYS_PROPERTIES
	/system/bin/cat /proc/version /proc/cmdline /system/build.prop > $LOG_PATH/EXP_0"$NUM_INFO"/SYS_VERSION_INFO
	/system/bin/cat /proc/vmstat > $LOG_PATH/EXP_0"$NUM_INFO"/SYS_VIRTUAL_MEMORY_STATS
	/system/bin/cat /proc/vmallocinfo > $LOG_PATH/EXP_0"$NUM_INFO"/SYS_VMALLOC_INFO
	/system/bin/cat /proc/zoneinfo > $LOG_PATH/EXP_0"$NUM_INFO"/SYS_ZONEINFO
	/system/bin/cat /proc/meminfo > $LOG_PATH/EXP_0"$NUM_INFO"/SYS_MEMINFO
	/system/bin/echo -n "disksize:" > $LOG_PATH/EXP_0"$NUM_INFO"/SYS_ZRAMINFO
	/system/bin/cat /sys/devices/virtual/block/zram0/disksize >> $LOG_PATH/EXP_0"$NUM_INFO"/SYS_ZRAMINFO
	/system/bin/echo -n "orig_data_size:" >> $LOG_PATH/EXP_0"$NUM_INFO"/SYS_ZRAMINFO
	/system/bin/cat /sys/devices/virtual/block/zram0/orig_data_size >> $LOG_PATH/EXP_0"$NUM_INFO"/SYS_ZRAMINFO
	/system/bin/echo -n "compr_data_size:" >> $LOG_PATH/EXP_0"$NUM_INFO"/SYS_ZRAMINFO
	/system/bin/cat /sys/devices/virtual/block/zram0/compr_data_size >> $LOG_PATH/EXP_0"$NUM_INFO"/SYS_ZRAMINFO
	/system/bin/echo -n "mem_used_total:" >> $LOG_PATH/EXP_0"$NUM_INFO"/SYS_ZRAMINFO
	/system/bin/cat /sys/devices/virtual/block/zram0/mem_used_total >> $LOG_PATH/EXP_0"$NUM_INFO"/SYS_ZRAMINFO


}

trim_logs()
{
	rm -r $LOG_PATH/EXP_00
	NUM_INFO=`expr $LOG_NUM_MAX - 1`
	N="1"
	while [ $N -lt $LOG_NUM_MAX ]
	do 
		TEMP=`expr $N - 1`
		mv $LOG_PATH/EXP_0$N $LOG_PATH/EXP_0$TEMP;
		N=`expr $N + 1`
	done
}

if test "$TAG" = "none"
then
	echo "*****************Tinno exp dump fail!!!!!!************************$TAG _ $PID";
else
	if [ $LOG_NUM -lt $LOG_NUM_MAX ]
	then
		NUM_INFO=$LOG_NUM;
		dump_logs;
	else
		echo "*****************Tinno exp dump file more than 10 !!!!!!************************$LOG_NUM";
		trim_logs;
		dump_logs;
	fi

fi
