#!/bin/bash
time=`date +%s`
mkdir -p /tmp/ssdtest/
log=/tmp/ssdtest/dd_test_$time.log
ramlog=/tmp/ssdtest/ramlog_dd_test_$time.log
#################
size=40000000
ssddev=/dev/sdc1
mountpoint=/data2
################
i=1
for bs in 4k 32k 64k;do
    #echo "###$i Write bs=$bs" >> $log
    bksize=`echo $bs|sed 's/k//g'`
    coun=`echo $size/$bksize|bc`
    echo "###$i write bs=$bs count=$coun" >> $log
    echo 3 > /proc/sys/vm/drop_caches
    dd if=/dev/zero of=${mountpoint}/40gssd_${bs} bs=$bs count=$coun conv=fdatasync 2>>$log
    sleep 3
    i=$((i+1))
done

#echo 1 > /proc/sys/vm/drop_caches; echo 0 > /proc/sys/vm/drop_caches;
for bs in 4k 32k 64k;do
    #echo "###$i Read test bs=$bs=========" >> $log
    bksize=`echo $bs|sed 's/k//g'`
    coun=`echo $size/$bksize|bc`
    echo "###$i read bs=$bs count=$coun" >> $log
    echo 3 > /proc/sys/vm/drop_caches
    dd if=${mountpoint}/40gssd_${bs}  of=/dev/null bs=$bs count=$coun  2>>$log

    i=$((i+1))
    echo "###$i Ramdev read bs=$bs=========" >> $ramlog
    echo 3 > /proc/sys/vm/drop_caches
    dd if=$ssddev of=/dev/null bs=$bs count=$coun 2>>$ramlog
    echo "###Test read ramdevend bs=$bs=========" >> $ramlog
    sleep 3
    i=$((i+1))
done

#check log

cat $log |egrep -v 'records'|xargs --max-line=2|awk -F"[,| ]" 'OFS=","{print $1,$2,$3,$(NF-1)$NF}' >/tmp/dd_report.txt
cat $ramlog |egrep -v 'records|Test'|xargs --max-line=2|awk -F"[,|=| ]" 'OFS=","{print $1,$2$3,$5,$(NF-1)$NF}' >> /tmp/dd_report.txt
cat /tmp/dd_report.txt
