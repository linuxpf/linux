1）在openstack-status脚本的基础上增加了监控，就不用再另外去写了
check_openstack.sh 监控脚本
openstack.cfg      zabbix配置文件

使用：
UserParameter=Openstack.parameter[*],/usr/local/check_openstack/check_openstack.sh $1
UserParameter=Openstack.openstack-nova-api,/usr/local/check_openstack/check_openstack.sh openstack-nova-api