#!/bin/bash 
#Test 
#################config ######
Time=180
DEVICE=/data/fio_full.test
iodepthnum=1
Ioengine=libaio
Filesize=40G
Jobnum=32
#######################
dir=/tmp/log
report_log=/tmp/report.txt
tmplog=/tmp/tmp1
output=/tmp/all_output.log
#dir=/tmp/log
>$report_log
#echo deadline > /sys/block/sda/queue/scheduler 
#echo 512 > /sys/block/sda/queue/nr_requests 
#echo 16 > /sys/block/sda/queue/read_ahead_kb 
echo " /sys/block/sda/queue/scheduler" >> $report_log
#/usr/local/monitor-base/bin/MegaCli -cfgdsply -aALL |grep Policy  >>$report_log
#/usr/local/monitor-base/bin/MegaCli -AdpBbuCmd -GetBbuCapacityInfo -aALL >> $report_log
mkdir -p /tmp/log/
hostname=`uname -n` 
declare -a tblocksize="(4k 64k 128k 512k 1024k 4096k)"
for i in  randwrite randread read write
do 
echo "Testing $i..." 
echo 3 > /proc/sys/vm/drop_caches 
	for BS in ${tblocksize[@]}
	do
    
	fio -filename=${DEVICE} -direct=1 -iodepth ${iodepthnum} -time_based -ioengine=${Ioengine} -rw=${i} -bs=${BS} -size=${Filesize} -group_reporting -numjobs=${Jobnum} -runtime=${Time}  \
		-name=${i}.log --output=/tmp/log/${hostname}_bs${BS}_${i}.log 
	echo "save log in /tmp/log/${hostname}_bs4k_$i.log"
    echo 3 > /proc/sys/vm/drop_caches
	sleep 60
	done
echo "save log in /tmp/log/${hostname}_bs4k_$i.log" 
done 



#check log########################################
cd $dir
output=/tmp/all_output.log
[ -f $output ] && rm -f $output
grep -A2 iops *.log |grep -v clat|sed 's/\-//g'| \
        xargs --max-line=2| \
          awk -F '[:|,|=|(|)]' 'OFS="," {print $1,$2,$6,$7,$8,$18,$11}'|sort>$tmplog
#blocksize 1k

#randread
echo "BS,BW,IOPS,LAT(us)" >>$output
echo "randread" >>$output
#echo "BS,BW(kbyte/s),IOPS,LAT(us)" >>$output
for i in ${tblocksize[@]}
do
  echo -n "$i," >> $output
  cat $tmplog |grep bs$i|awk -F"," '/randread/ && OFS="," {print $3,$4,$5,$6,$NF}'>>$output
done

echo "randwrite" >>$output
#randwrite
for i in ${tblocksize[@]}
do
  echo -n "$i," >>$output
  cat $tmplog |grep bs$i|awk -F"," '/randwrite/&& OFS="," {print $3,$4,$5,$6,$NF}'>>$output
done

#read
echo "read" >>$output
for i in ${tblocksize[@]}
do
  echo -n "$i," >>$output
  cat $tmplog|grep bs$i|egrep -v "readwrite|randrw|randread"| \
             awk -F"," '/read/ && OFS=","  {print $3,$4,$5,$6,$NF}' >>$output

done

#write
echo "write" >>$output
for i in ${tblocksize[@]}
do
 echo -n "$i," >>$output
 cat $tmplog|grep bs$i|egrep -v "readwrite|randrw|randwrite"| \
            awk -F"," '/write/ && OFS=","  {print $3,$4,$5,$6,$NF}'>>$output

done

cat $output |awk -F"," 'OFS="," {if($NF =="msec") print $1,$2,$3,$4,$5*1000;else print $1,$2,$3,$4,$5 }'>/tmp/1.log
