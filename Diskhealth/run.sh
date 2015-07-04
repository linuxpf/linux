#!/bin/bash
#update 20150701
dir="/usr/local/caiji"
flag="$dir/log/run.id"
if [ ! -f $flag ];then
    echo "" > $flag
fi
if [ `cat $flag |grep 'run'|wc -l` -gt 0 ];then
    sps=`ps -ef|grep 'run.sh'|grep 'caiji' |wc -l`
    if [ $sps -gt 2 ]
    then
        echo "exit"
        exit
    fi
fi
echo "run" > $flag

host=`uname -n`

####commit uplog info to zabbix
zabbixserver="zabbix.youdoamin.com"
zabbixport=10051
###
time=`date +%s`
DATE_BASE=$((`date +%s`/60*60))
info_log="$dir/log/allraid.log"
>$info_log

###
pcilog="/tmp/pci.log"
[ ! -f $pcilog ]  && /sbin/lspci -m | grep -iE "sas|raid" > $pcilog

###check lsi MegaRAID status
$dir/bin/check_raid.sh

###check Disk_Health
$dir/bin/Disk_Health.sh

###check mdadm softraid
$dir/bin/check_mdraid.sh

###sende to zabbix server
/usr/bin/zabbix_sender -z ${zabbixserver} -p ${zabbixport} -T -i $info_log
echo "" > $flag
