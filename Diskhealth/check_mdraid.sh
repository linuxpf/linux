#!/bin/bash
#20150701
dir="/usr/local/caiji"
log="$dir/log/mdadm_stat.log"
mdadm_con="/etc/mdadm.conf"
host=`uname -n`
time=`date +%s`
DATE_BASE=$((`date +%s`/60*60))
SoftRaid=0
info_log="$dir/log/allraid.log"

[ ! -f $mdadm_con ] && echo "not found $mdadm_con" && exit 1
mdevice=`cat $mdadm_con|awk '/ARRAY/{print $2}'`
[ -z $mdevice ] && echo "not found $mdadm_con" && exit 1

[ ! -f $log ] && /sbin/mdadm -D $mdevice > $log
[ `date +%M` = "01" ] && /sbin/mdadm -D $mdevice > $log


State=`cat $log|grep State|grep -v Number|awk -F"[:|,]" '{print $2}'`
Failed=`cat $log|grep 'Failed Devices'|awk -F": " '{print $2}'`

if [ $Failed -ne 0 ]; then
    Title="mdadm Failed Devices : $Failed|$host"
    SoftRaid=$Failed
elfi [ `cat $log|grep State|grep -v Number|egrep -i degraded|wc -l` -gt 0 ];
     SoftRaid=1
elif [ $State != "clean" -a $State != "active" ];then
    Title="mdadm State : $State|$host"
    SoftRaid=1
else
    echo 'mdadm check ok'
    SoftRaid=0
fi
echo "$host SoftRaid $DATE_BASE $SoftRaid" >>$info_log
