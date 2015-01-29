#!/bin/sh
#
source_ip=$1
#
declare -a officegroup="(8.8.8.8)"
port=30000
start=100
################
if [ -z $source_ip ]; then
/sbin/modprobe ip_tables
/sbin/modprobe iptable_filter
/sbin/modprobe iptable_nat
/sbin/modprobe ip_conntrack
/sbin/modprobe ip_conntrack_ftp
/sbin/modprobe ip_nat_ftp
/sbin/iptables -F
/sbin/iptables -t nat -F
/sbin/iptables -Z
#port prerouting
echo 1 > /proc/sys/net/ipv4/ip_forward
##############
#start=100
#port=30000
vm_port=${vm_port:=3389}

###########
#port2=50000
#vm_port2=22

##10.9.9.1-2 XP
for ii in `seq 1 20`
  do
   port=$((port+1))
   start=$((start+1))
   vm_ip="172.16.10.${start}"
   echo "$port ${vm_ip}:${vm_port}"
   for sip in ${officegroup[@]};do
       /sbin/iptables -t nat -A PREROUTING -p tcp -s $sip --dport $port -j DNAT --to ${vm_ip}:${vm_port}

       if [ -n "$vm_port2" -a -n "$port2" ]; then
          port2=$((port2+1))
          /sbin/iptables -t nat -A PREROUTING -p tcp -s $sip --dport ${port2} -j DNAT --to ${vm_ip}:${vm_port2}
       fi

   done
done
#### POSTROUTING   NAT
/sbin/iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
#### INPUT
/sbin/iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
##################
/sbin/iptables -A FORWARD -p icmp -j ACCEPT
/sbin/iptables -A FORWARD -p tcp -m multiport --dport 21,22,3389 -j ACCEPT
/sbin/iptables -A FORWARD -p tcp -m multiport --sport 21,22,3389 -j ACCEPT
/sbin/iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
#/sbin/iptables -nvL -t nat
##############################################
else
#port=30000
#start=100
vm_port=${vm_port:=3389}
echo $source_ip
for ii in `seq 1 20`;
do
   port=$((port+1))
   start=$((start+1))
   vm_ip="172.16.10.${start}"
   echo "$port ${vm_ip}:${vm_port}"
/sbin/iptables -t nat -A PREROUTING -p tcp -s ${source_ip}  --dport $port -j DNAT --to ${vm_ip}:${vm_port}
done
fi
/sbin/iptables -nvL -t nat
