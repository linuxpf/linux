#!/bin/bash
if [ $# -ne 1 ];then
    echo "Usage: $0 <servicename>"
    exit 1
fi 

log=/tmp/check_openstack.log
tmp=/tmp/openstack.tmp
time=`date +%M`
[ ! -s $log ] && /usr/bin/openstack-status 2>&1 |egrep -v 'disabled on boot|=|not sourced' >$log
[ ! -s $tmp  -o $((time%30)) -eq 10 ] && /usr/bin/openstack-status 2>&1 |egrep -v 'disabled on boot|=|not sourced' >$tmp


get_status(){
        h_srv=`cat $log|grep -i $1|awk '{print $NF}' 2>/dev/null`
	n_srv=`cat $tmp|grep -i $1|awk '{print $NF}' 2>/dev/null`
	if [ "$n_srv" == "active" -a "$h_srv" == "active" ]; then
	    check_srv=0
	elif [ -n "$n_srv"  -o -n "h_srv" ];then
	    check_srv=2
	else 
	    check_srv=1
	fi
}
get_status $1
echo "$check_srv"
