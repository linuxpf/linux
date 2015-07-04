#!/bin/bash
#
dir="/usr/local/caiji"
time=`date +%s`
DATE_BASE=$((`date +%s`/60*60))
host=`uname -n`
info_log="$dir/log/allraid.log"
smartmon()
{
    dev=$1
    /usr/sbin/smartctl -H $dev
    RETVAL=$?
    if [ $RETVAL -ne 0 ];then
        echo "$dev not support smartmontools"
        continue
    fi
    Health=`/usr/sbin/smartctl  -H $dev|grep -iE  "SMART|health"|tail -1 |awk -F": " '{print $2}'`
    if [[ $Health = [Oo][Kk]* ]]|| [  "$Health" = "PASSED" ];then
        HD_Stat="Online"
        echo -e "\033[32;1m$dev $HD_Stat PASSED\033[0m" 
    else
        HD_Stat="Failed"
        smarfailed=$((smarfailed+1))
    fi
}

smarfailed=0
bldev=(`/sbin/parted -l |grep -i Disk|grep -v VolGroup|awk -F"[:| ]" '{print $2}'`)
#bldev=(`ls -l /dev/disk/by-path/ | grep scsi | grep -v part | awk -F'/' '{printf$NF" "}'`)
for bldev in ${bldev[@]}; do
    [ ! -b $bldev ] && continue
     smartmon $bldev
done
echo "$host disk_smarfailed  $DATE_BASE $smarfailed" >>$info_log
