#!/bin/bash 
if [ $# -ne 1 ];then
    echo "usage: $0 <daily|monthly|33day>"
    exit 1
fi
dir="/usr/local/check_mrtg"
date=`date +%Y-%m-%d`
echo "$date"
if [[ "$1" == "daily" ]] || [[ "$1" == "monthly" ]] || [[ "$1" == "33day" ]]; then
   echo "running $1"
else 
  echo "usage: $0 <daily|monthly|33day>"
  exit 1 
fi

while read SW LOG GWIP;do
    logfile="/usr/local/mrtg/htdocs/$SW/$LOG"
    if [ -f $logfile ];then
       $dir/bin/mrtg_max2015.py $logfile $1
    fi
done< $dir/conf/sw_mrtg.checklist | grep -v ^#

if [ "$1" == "33day" ];then
   echo "save log"
   [ ! -d $dir/data/${date} ] && mkdir -p $dir/data/${date}
   mv $dir/data/*.log $dir/data/${date}
fi
