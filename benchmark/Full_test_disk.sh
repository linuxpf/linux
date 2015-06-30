#!/bin/bash 
#Test 
[ $# -ne 1 ] && exit 1
#################config ######
Time=180
DEVICE="/dev/sdc1"
iodepthnum=1
Ioengine=libaio
Filesize=200G
Jobnum=32
item=$1
#######################
dir="/root/log/${item}"
report_log="/root/report/${item}_iodepthnum${iodepthnum}_${Ioengine}_report.txt"
tmplog=/tmp/tmp1
#echo deadline > /sys/block/sda/queue/scheduler 
#echo 512 > /sys/block/sda/queue/nr_requests 
#echo 16 > /sys/block/sda/queue/read_ahead_kb 
#echo " /sys/block/sda/queue/scheduler" >> $report_log
mkdir -p /root/log/${item}
mkdir -p /root/report
echo ''>$report_log
[ ! -d $dir ] && mkdir -p $dir
hostname=`uname -n` 
declare -a tblocksize="(4k 32k 64k)"
for i in  randwrite randread read write readwrite randrw
do 
echo "Testing $i..." 
echo 3 > /proc/sys/vm/drop_caches 
	for BS in ${tblocksize[@]}
	do
        info_log="$dir/${hostname}_bs${BS}_${i}_${iodepthnum}.log"
	fio -filename=${DEVICE} -direct=1 -iodepth ${iodepthnum} -time_based -ioengine=${Ioengine} -rw=${i} -bs=${BS} -size=${Filesize} -group_reporting -numjobs=${Jobnum} -runtime=${Time}  \
		-name=${i}.log --output=${info_log}
       #rm -f ${DEVICE}_${BS}
	echo "save log in ${info_log}"
        echo 3 > /proc/sys/vm/drop_caches
	sleep 60
	done
echo "save log in ${info_log}" 
done 



#check log########################################
cd $dir
output="/tmp/all_output.log"
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


echo "randrw_read" >>$output
#randrw_read
for i in ${tblocksize[@]}
do
 echo -n "$i," >>$output
 cat $tmplog|grep bs$i|grep randrw| \
            awk -F"," '/read/ && OFS=","  {print $3,$4,$5,$6,$NF}'>>$output

done

echo "randrw_write" >>$output
#randrw_write
for i in ${tblocksize[@]}
do
 echo -n "$i," >>$output
 cat $tmplog|grep bs$i|grep randrw| \
            awk -F"," '/write/ && OFS=","  {print $3,$4,$5,$6,$NF}'>>$output

done
echo "readwrite_read" >>$output
#readwrite_read
for i in ${tblocksize[@]}
do
 echo -n "$i," >>$output
 cat $tmplog|grep bs$i|grep readwrite|awk -F"," '($2 ~ /read/) && OFS="," {print $3,$4,$5,$6,$NF}' >>$output
done

echo "readwrite_write" >>$output
#readwrite_write
for i in ${tblocksize[@]}
do
 echo -n "$i," >>$output
 cat $tmplog|grep bs$i|grep readwrite|awk -F"," '($2 ~ /write/) && OFS=","  {print $3,$4,$5,$6,$NF}' >>$output
done

#format values
cat $output |awk -F"," 'OFS="," {if($NF =="msec") print $1,$2,$3,$4,$5*1000;else print $1,$2,$3,$4,$5 }'>$report_log
