#!/bin/bash
#Centos5 or Centos6 20150210 by linuxpf
#Disabled SUID Core Dumps
echo '0' > /proc/sys/fs/suid_dumpable
grep -q suid_dumpable /etc/rc.d/rc.local || echo "echo '0' > /proc/sys/fs/suid_dumpable" >> /etc/rc.d/rc.local

#disabled source_route /etc/sysctl.conf 
sed -i 's/net.ipv4.conf.default.accept_source_route.*/net.ipv4.conf.default.accept_source_route = 0/g' /etc/sysctl.conf
if ! fgrep net.ipv4.conf.default.accept_redirects /etc/sysctl.conf; then
     sed -i '/net.ipv4.conf.default.accept_source_route/a net.ipv4.conf.default.accept_redirects = 0\nnet.ipv4.conf.default.secure_redirects = 0' /etc/sysctl.conf
fi
#Prevent icmp attack and tcp syncookie enabled
sed -i 's/net.ipv4.tcp_syncookies.*/net.ipv4.tcp_syncookies = 1/g' /etc/sysctl.conf
[ `cat /etc/sysctl.conf |grep '^net.ipv4.icmp_echo_ignore_broadcasts'|wc -l` -lt  1 ] && \
sed -i '/net.ipv4.tcp_syncookies/a # Prevent icmp attack\nnet.ipv4.icmp_echo_ignore_broadcasts = 1' /etc/sysctl.conf
sysctl -p > /dev/null

##
if [ ! -f /etc/modprobe.conf ] ; then
   
   touch /etc/modprobe.d/dis-filemodule.conf
cat << 'EOF' > /etc/modprobe.d/dis-filemodule.conf
install cramfs /bin/true
install freevxfs /bin/true
install jffs2 /bin/true
install hfs /bin/true
install hfsplus /bin/true
install squashfs /bin/true
install udf /bin/true
install ppp_generic /bin/true
install pppoe /bin/true
install pppox /bin/true
install slhc /bin/true
install bluetooth /bin/true
install ipv6 /bin/true
install irda /bin/true
install ax25 /bin/true
install x25 /bin/true
install ipx /bin/true
install appletalk /bin/true
EOF
else
if ! fgrep 'define disabled' /etc/modprobe.conf; then
  cat << 'EOF' >> /etc/modprobe.conf
install cramfs /bin/true
install freevxfs /bin/true
install jffs2 /bin/true
install hfs /bin/true
install hfsplus /bin/true
install squashfs /bin/true
install udf /bin/true
install ppp_generic /bin/true
install pppoe /bin/true
install pppox /bin/true
install slhc /bin/true
install bluetooth /bin/true
install ipv6 /bin/true
install irda /bin/true
install ax25 /bin/true
install x25 /bin/true
install ipx /bin/true
install appletalk /bin/true
#define disabled 
EOF
  fi
fi

#check gpgcheck gpgcheck=1
rpm -q --queryformat "%{SUMMARY}\n" gpg-pubkey|egrep -q 'CentOS . Official Signing Key|Red Hat, Inc'  && echo -e "\033[32;1mGPG Check normal\033[0m" \
    || yum -y install gnupg	
fgrep -q  'gpgcheck=1' /etc/yum.conf ||sed -i 's/gpgcheck.*/gpgcheck=1/g' /etc/yum.conf
find /etc/yum.repos.d/* | xargs grep "gpgcheck=0" && \
     find /etc/yum.repos.d/* | xargs grep "gpgcheck=0" |cut -d':' -f 1|xargs sed  -i 's/gpgcheck=0/gpgcheck=1/g'
#check file uid
find / -path /proc  -prune -o \( -nouser  -o -nogroup \)  -print > /tmp/nouid_file.txt
[ `cat /tmp/nouid_file.txt |wc -l ` -gt 0 ] && echo -e '\033[31;1mfind no uid or nogroupid file list /tmp/nouid_file.txt\033[0m'

#delete unnecessary user and groups
chattr -i /etc/shadow
chattr -i /etc/passwd
{
userdel adm
userdel lp
userdel sync
userdel shutdown
userdel halt
userdel news
userdel uucp
userdel operator
userdel games 
userdel gopher
groupdel adm
groupdel lp
groupdel sync
groupdel shutdown
groupdel halt
groupdel news
groupdel uucp
groupdel operator
groupdel games 
groupdel gopher
} >/dev/null

#check Root uid exclude root
User=`awk -F: '($3 == "0" && $1 != "root" && $1 != "superuser") {print}' /etc/passwd|cut -d':' -f1`
[ ! -z $User ] && echo -e "\033[31;1mfind dangerous user: $User \033[0m" || echo 'passwd file normal'
#.....
[ `awk -F: '($2 == "") {print}' /etc/shadow|wc -l` -lt 1 ] ||\
  echo -e "\033[31;1mPlease set user:`awk -F: '($2 == "") {print$1}' /etc/shadow` password\033[0m"

chmod go-w /root
for user in `ls -1 /home/`
do
    chmod go-w /home/$user
    chmod go-w /home/$user/.[A-Za-z0-9]*
done

#umask check
if ! fgrep 'umask 077' /etc/profile > /dev/null; then
cp /etc/profile /etc/profile_backup
#centos6
sed -i -e 's/umask 002/#umask 002/g' -e '/umask 002/a umask 077' \
       -e 's/umask 022/#umask 022/g' -e '/umask 022/a umask 077'  /etc/profile
#centos5
grep -q 'umask 077' /etc/profile || echo 'umask 077' >> /etc/profile

fi
declare Profile=(/root/.bashrc /root/.bash_profile /root/.cshrc /root/.tcshrc)
for  file in ${Profile[@]};
do
[ `cat $file |grep '^umask 077'|wc -l` -lt 1 ] &&\
echo 'umask 077' >> $file
done
#ftp NETRC
for NETRC in `ls -1 /home/*/.netrc`; 
do
echo 'ftp passwd file deleting'
#rm -f  $NETRC
[ -n $NETRC ] && rm -f  $NETRC
done

#system-auth 
\cp /etc/pam.d/system-auth /etc/pam.d/system-auth_backup
sed -i 's/pam_cracklib.so.*$/pam_cracklib.so try_first_pass retry=3 minlen=12 minclass=3/g'  /etc/pam.d/system-auth-ac
sed -i '/password    sufficient    pam_unix.so/ s/use_authtok$/use_authtok remember=5/g'  /etc/pam.d/system-auth-ac
sed -i '/auth        sufficient    pam_unix.so/ s/sufficient/required/g' /etc/pam.d/system-auth-ac
sed -i -e  '/pam_succeed_if.so uid >= 500/ s/^auth/#auth/g' \
      -e '/auth        required      pam_deny.so/ s/^auth/#auth/g' /etc/pam.d/system-auth-ac 

#password 365 expire
#chage -M 365 -m 7 -W 7 root
if [ `cat /etc/pam.d/sshd |grep pam_tally2.so|wc -l` -lt 1 ]; then
sed -i '/PAM-1.0/aauth       required     pam_tally2.so deny=5 unlock_time=300\naccount    required     pam_tally2.so' /etc/pam.d/sshd
fi
yum  -y erase pam_ccreds >/dev/null 2>1


#centos6 check
#/etc/ssh/sshd_config
sed -i 's/#RhostsRSAAuthentication no/RhostsRSAAuthentication no/g' /etc/ssh/sshd_config
[ ` cat /etc/ssh/sshd_config|grep Protocol |grep -v '#'|awk '{print $2}' ` != "2" ] && echo 'Check sshd Protocol' || echo 'sshd Protocol normal'
grep -q '^HashKnownHosts' /etc/ssh/ssh_config|| echo 'HashKnownHosts yes' >> /etc/ssh/ssh_config 
sed -i -e 's/#MaxAuthTries.*$/MaxAuthTries 5/g'  -e 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' \
       -e 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' /etc/ssh/sshd_config
#centos5 check
grep -q '^MaxAuthTries'  /etc/ssh/sshd_config|| echo 'MaxAuthTries 5' >> /etc/ssh/sshd_config
grep -q '^PermitEmptyPasswords'  /etc/ssh/sshd_config || echo 'PermitEmptyPasswords no' >> /etc/ssh/sshd_config

service sshd restart
