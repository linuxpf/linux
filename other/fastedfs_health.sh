#!/bin/bash
#monitor fastdfs health

basedir=`dirname $0`
tmpdir=/tmp/
host_name=`uname -n`
delay_range=300
webcaht_tos="user"
nowtime=`date +%s`
status="$basedir/brief_status.log"
tmp1=$tmpdir/active.log
tmp2=$tmpdir/syn_time.log
info=$tmpdir/fastdfs_info.log

url="url"

/usr/local/tfdfs/bin/fdfs_monitor  /usr/local/tfdfs/conf/client.conf list >$info 2>&1
awk '/ip_addr/ {print $3,$5}'  $info >$tmp1
awk '/last_synced_timestamp/ {print $3,$4}' $info >$tmp2
/usr/bin/paste ${tmp1} ${tmp2} > $status
echo -e "\033[32mfdfs_monitor:\n`cat $status`\033[0m"
i=0;cnt=0
while read host stat day time;do
    tick=`date -d "$day $time" +%s`
    delay_time=0
    [ "$tick" -gt 0 ] && delay_time=$(($nowtime-$tick))
    if [ "$stat" != "ACTIVE" ];then
        echo -e "\033[33storage status $host: status=$stat $day $time\033[0m"
        cnt=$((cnt+1))
    fi
    if [ $delay_time -gt "$delay_range" ];then
        echo -e "\033[33mcheck storage last_synced_timestamp $host:$stat $day $time\033[0m"
        i=$((i+1))
    fi
done <"$status"

#alarm_method
alarm_method(){
    content=$1
    method=$2
    range="***"
    if [ "$method" == "webchat" ];then
        echo "send webchat"
        range="*****"
        #send_webchat
    fi
    echo "send mail"
    #sendmail
}

#check health
ac=`wc -l $status|awk '{print $1}'`
bc=`grep -c 'ACTIVE' $status`

if [ "$bc" -lt "$ac" -o "$cnt" -gt 0 ];then
    echo -e "\033[31check mfdfs status \033[0m"
    content="fastdfs health storage Inactive alarm  from $host_name"
    alarm_method "$content" webchat
fi
if [ "$i" -gt 1 ];then
    echo -e "\033[31mfdfs last_synced_timestamp\033[0m"
    content="fastdfs synced_timestamp  alarm from $host_name"
    #alarm_method "$content" mail
fi
