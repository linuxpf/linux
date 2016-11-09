#!/bin/bash

i=0
while [ $i -lt 1 ];do
#echo $i;
pid=`top -bn1 |awk '/netstat/{print $1}'`; 

if [ ! -z $pid ];then
   ppid=`ps -ef |grep -i $pid|grep -v grep|awk '{print $3}'`;
   fpidnum=`ps -ef |grep -i $ppid|grep -v 'grep -i' |awk '{print $3}'|grep -v $ppid`;
   #echo $ppid; 
   lsof -p $ppid;
   echo "$pid lsof ================"
   lsof -p $pid; 
   echo "$ppid proc ================"
   ls -alh  /proc/$ppid/;
   echo "$pid proc ================"
   ls -alh  /proc/$pid/;
   echo "$ppid cmdline ================"
   cat  /proc/$ppid/cmdline;
   echo "$pid cmdline ================"
   cat  /proc/$pid/cmdline;    
   
   echo "$pid cwd ================"
   ls -ltrh  /proc/$ppid/cwd;    
    echo "$pid ps ================"
   ps -ef |grep -i $pid;
    echo "$ppid ps ================"
   ps -ef |grep -i $ppid;
   echo "################################"
   echo "$fpid check ps ================"
   for id in $fpidnum;do
       echo $id
       ps -ef |grep -i $id;
   done
fi
done
