#!/bin/bash
#mtr -n $host to zabbix_sever 
export PATH="/usr/kerberos/sbin:/usr/kerberos/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/home/root1/bin"
HOST=`hostname`
DATE_BASE=$((`date +%s`/60*60))
HOSTNAME=`hostname | awk -F. '{print $1}' | sed 's/-//g'`
cd /usr/local/caiji
dir="/usr/local/caiji"
zabbix_server="123.domain.com"
host=`hostname`
iplist="$dir/log_tmp/ip.txt"
api_url=""

if [ ! -d $dir/log_tmp ];then
    mkdir -p $dir/bin/ $dir/log/ $dir/log_tmp/
fi

t=`echo $host | grep "^t" | wc -l`
c=`echo $host | grep "^c" | wc -l`
m=`echo $host | grep "^m" | wc -l`

down_iplist(){
if [ $t -eq 1 ];then
    curl -s "$api_url" > $iplist
else
   exit 0;
fi
}

[ ! -f $iplist ] && down_iplist
DATE1=`date +%s`
DATE=`date "+%Y-%m-%d %H:%M"`


read_mtr(){
    while read id ip Loss Snt Last Avg Best Wrst StDev; do
        hop_rtt="hop${i}_rtt"
        hop_loss="hop${i}_loss"
        id=`echo $id|tr '.' ' '`
        Loss=`echo $Loss|tr '%' ' '`
        printf "%s\t%s\t%s\t%s\n" $id $ip $Loss $Avg
        [ -z $id ]&& id=0
        [ -z $Loss ]&& Loss=0
        [ -z $Avg ]&& Avg=0
        echo "${MONITOR_HOST} ${hop_rtt} ${DATE_BASE} ${Avg} " >> $upload_log
       #echo "${MONITOR_HOST} ${hop_loss} ${DATE_BASE} ${Loss} " >>$upload_log
        i=$((i+1))
    done

}


function check_route(){
    IP=$1
    MONITOR_HOST=$2
    info="$dir/log_tmp/mtr${IP}.log.test"
    upload_log="$dir/log_tmp/zabbix.mtr_${IP}.log.test"
    [ -f $upload_log ] && rm -f $upload_log
    mtr --n --report $IP >$info

    #save log
    timetick=`date +%H`
    end=`date -d "2 day ago" +%s`
    now=`date +%s`
    [ ! -d /tmp/mtr ] && mkdir -p  /tmp/mtr
    save_log="/tmp/mtr/mtr${IP}.logtest"
    if [ ! -f $save_log  ];then
        echo "time_flag=$now" >> $save_log
    fi
    if [ `cat $save_log|grep time_flag|awk -F"=" '{print $2}'` -lt $end ];then
       rm -f $save_log
       echo "time_flag=$now" >> $save_log
    fi
    echo "$DATE===================" >> $save_log
    cat $info|grep -vE "Snt|Start"|awk '{printf "%-18s %-18s %-10s",  NR ") "$2, "Loss["$3"]", "Dleay["$6"]  ";system("whois "$2"|grep descr|head -n1|cut -c17-");printf "\n"}' >>$save_log

    [ ! -s $info ] && continue
    rnums=`cat $info|grep -v HOST|wc -l`
    if [ $rnums -ge 10 ];then
       i=1
       cat $info|egrep  -v HOST|head -n 5|read_mtr
       i=6
       cat $info|egrep  -v HOST|tail -n 5|read_mtr
    else
       i=1
       cat $info|egrep  -v HOST|read_mtr
    fi
    /usr/bin/zabbix_sender -z ${zabbix_server} -p 10051 -T -i  $upload_log
    echo $upload_log
}

#iplist="/tmp/tmp.txt"
cat $iplist | while read monitor_host ip;do
check_route $ip $monitor_host
done
