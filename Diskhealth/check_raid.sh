#!/bin/bash
#if [ $# -ne 1 ] ; then
#    echo "usage: $0 <host>"
#    exit 1
#fi
#20150701
host=`uname -n`
dir="/usr/local/caiji"
log="$dir/log/check_raid_current.log"
disklog="$dir/log/disk_num.log"
adpInfo_log="$dir/log/AdpAllInfo.log"
uplog="$dir/log/check_uploadraid.log"
info_log="$dir/log/allraid.log"
time=`date +%s`
DATE_BASE=$((`date +%s`/60*60))
host=`uname -n`

#zabbixserver=""
#zabbixport=10051

[ `arch` == "x86_64" ] && diskutil="/opt/MegaRAID/MegaCli/MegaCli64" || diskutil="/opt/MegaRAID/MegaCli/MegaCli"
[ ! -f $diskutil ] && diskutil="$dir/bin/MegaCli"

#check lsi MegaRAID
pcilog="/tmp/pci.log"
if [ `cat $pcilog | grep -E "RAID bus controller|RAID controller" | grep -E "MegaRAID|PERC|PowerEdge Expandable RAID controller|MegaSAS" | wc -l` -lt  1 ]; then
    echo 'not found lsi MegaRAID'
    exit 1
fi

#echo "time:$time">$uplog
#check raid status
check_status(){
    slot=(`cat $log | awk '/Slot/ {print$NF}'`)
    pd_num=`cat $log | awk '/Slot/ {print$NF}'|wc -l`
    state=(`cat $log | awk -F[\ ,] '/Firmware state/{print$3}' | awk 'BEGIN{IGNORECASE=1}{if($1 ~ "online|jbod"){print "Online"}else if($1 ~ "hot"){print "Hotsp"}else if($1 ~ "build"){print "Build"}else{print "Failed"}}' `)
    #size=(`cat $log | awk -F' |MB|TB' '/Raw Size:/ { if($3>100000) {printf "%dGB\n",$3/1000} else if($3<10) {printf "%dGB\n",$3*1000} else {printf "%dGB\n",$3} }'`)
    size=(`cat $log | awk '/Raw Size/ {if($4 ~ TB) {printf "%dGB\n",$3*1000} else if($4 ~GB) {printf "%dGB\n",$3}  else {printf "%dGB\n",$3/1000}}'`)
    Inquiry=(`cat $log|awk '/Inquiry Data/{print $3"/"$4}'`)
    for i in `seq 0 $((${#slot[@]}-1))`;do
        echo "slot:${slot[$i]} ${state[$i]} ${size[$i]} ${Inquiry[$i]}" >>$uplog
    done
    #cat $log |awk -F':' '{print $2 $3}' |awk 'BEGIN{IGNORECASE=1}{if($4 ~ "online"){print $1,"Online"}else if($4 ~ "hot"){print $1,"Hotsp"}else if($4 ~ "build"){print $1,"Build"}else{print $1,"Failed"}}'
    critical_num=`cat $adpInfo_log| awk '/Critical Disks/{print$NF}'`
    #critical_num=`$diskutil -AdpAllInfo -aALL -nolog | awk '/Critical Disks/{print$NF}'`

    if [ -z $critical_num -o $critical_num -eq 0 ];then
        critical_num=`cat $log|grep "Firmware state:"|egrep -iv 'Hotspare|Online|JBOD'|wc -l`
        if [ `cat $disklog|grep "Slot Number"|wc -l` -ne `cat $log|awk '/Slot/{print$NF}'|wc -l` ];then
            critical_num=3
        fi
    fi

}
#current log
if [ `date +%M` = "01" -o ! -f $log ]; then
    $diskutil -PDList -aALL -nolog> $log
    ctl_type=`$diskutil -cfgdsply -aALL -nolog |grep "Product Name" |awk -F': ' '{print $2}'`
    echo "ctrl_type:$ctl_type ctrl_id=1" >>$log
    $diskutil -AdpAllInfo -aALL -nolog >$adpInfo_log
fi
#first log
if [ ! -f "$disklog" ];then
    $diskutil -PDList -aALL -nolog> $disklog
fi    

#raid status
check_status

echo "critical_num:$critical_num" >>$uplog
echo "$host critical_num  $DATE_BASE $critical_num" >>$info_log
echo "$host pd_num  $DATE_BASE $pd_num" >>$info_log
ctl_type=`cat $log|awk -F":" '/ctrl_type/{print $NF}'` 
echo "ctrl_type:$ctl_type" >>$uplog


#sende to zabbix server
#/usr/bin/zabbix_sender -z ${zabbixserver} -p ${zabbixport} -T -i $info_log
