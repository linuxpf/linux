#!/bin/bash
#20140225 by linuxpf
ODEV=eth1
IDEV=eth0
MAXUP=1mbit
UP=1mbit
MAXDOWN=4mbit
DOWN=4mbit
######################
echo 1 > /proc/sys/net/ipv4/ip_forward
/sbin/iptables -t mangle -F

tc qdisc del dev $ODEV root 2> /dev/null
tc qdisc del dev $IDEV root 2> /dev/null

tc qdisc add dev $ODEV root handle 100: htb default 256
tc class add dev $ODEV parent 100: classid 100:1 htb rate 1000Mbit


#tc qdisc add dev $IDEV root handle 200: htb default 256
tc qdisc add dev $IDEV root handle 200: cbq bandwidth 1000Mbit cell 8 avpkt 1000
#tc class add dev $IDEV parent 200: classid 200:1 htb rate 1000Mbit


i=3

while [ $i -le 125 ]
do
IPADD="10.9.9.$i"
#up
tc class add dev $ODEV parent 100:1 classid 100:2$i htb rate  $UP ceil $MAXUP prio 1
tc qdisc add dev $ODEV parent 100:2$i sfq quantum 1514b perturb 15
tc filter add dev $ODEV parent 100: protocol ip prio 5 handle $i fw classid 100:2$i
iptables -t mangle -I POSTROUTING -o eth1  -s $IPADD  -j RETURN
iptables -t mangle -I POSTROUTING -o eth1  -s $IPADD  -j MARK --set-mark $i

#down 
tc class add dev ${IDEV} parent 200: classid 200:$i cbq bandwidth 1000mbit rate $DOWN weight $MAXDOWN prio 5 allot 1514 cell 8  maxburst 20 avpkt 1000 bounded isolated
tc filter add dev ${IDEV} protocol ip parent 200: prio 5 u32 match ip dst $IPADD  flowid 200:$i
i=`expr $i + 1`
done
