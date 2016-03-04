#!/bin/bash
###config 定义配置
wan_dev=eth1
lan_dev=eth0
port=9103
#declare  -a ports_array={9103}
###

#clear iptables mangle rules
/sbin/iptables -t mangle -F
#clear tc qdisc rules
/sbin/tc qdisc del dev $ODEV root 2> /dev/null
#/sbin/tc qdisc del dev $IDEV root 2> /dev/null

#打开队列规则 rule 100
/sbin/tc qdisc add dev $lan_dev root handle 100: htb default 256
#最大带宽300mbit,突发带宽500mbit
/sbin/tc class add dev $lan_dev parent 100: classid 100:10 htb rate 500Mbit ceil 600Mbit prio 0

#出去tcp 源端口作标记为1
/sbin/iptables -A OUTPUT -t mangle -p tcp --dport ${port} -j MARK --set-mark 10

#绑定规则
/sbin/tc filter add dev $lan_dev parent 100: prio 0 protocol ip handle 10 fw flowid 100:10
