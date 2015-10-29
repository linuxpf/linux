#!/usr/bin/env python
#20151028
import sys,os,time
import pycurl
import random,errno
from cStringIO import StringIO
from multiprocessing import Pool
import socket
import fcntl
import struct
import commands


def Getdata(url, path):
    buf = StringIO()
    head = ['HOST:test.baidu.com','User-Agent:Mozilla/5.0 (Windows NT 5.1; rv:25.0) Gecko/20100101 Firefox/24.3', 'Cookie: gdriveid=4B3AA23F722CEACB20719A7AD77E28D3']
    handle = pycurl.Curl()
    handle.setopt(pycurl.URL, url)
    handle.setopt(pycurl.HTTPHEADER,  head)
    handle.setopt(pycurl.WRITEFUNCTION, buf.write)
    handle.setopt(pycurl.TIMEOUT, 30)
    handle.setopt(pycurl.FOLLOWLOCATION, True)
    handle.perform()
    http_code = handle.getinfo(pycurl.HTTP_CODE)
    if http_code == 200:
        print url, http_code
        content = buf.getvalue()
        buf.close()
        f = open(path, 'wb+')
        f.write(content)
        f.close()
    else:
        line = "%s\t%s\n" % (url, http_code)
        err.write(line)
    #f=StringIO(content)
    #return content

def get_localaddr(ifname):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    return socket.inet_ntoa(fcntl.ioctl(
        s.fileno(),
        0x8915,  # SIOCGIFADDR
        struct.pack('256s', ifname[:15])
    )[20:24])

# get max bandwidth
def get_localhost_bandwidth_max():
    cmd = "netstat -rn|grep ^0.0.0.0|grep UG|awk '{print $NF}'| xargs vnstat -tr 2 -i | grep -e tx | awk '{print $2, $3}'"
    bandwidth_array=[]
    for k in range(20):
        (status, output) = commands.getstatusoutput(cmd)
        if status==0:
            lines = output.split("\n")
            bandwidth = 0
            for line in lines:
                arr = line.split(" ")
                if len(arr) == 2:
                    bwtmp = float(arr[0])
                    unit = arr[1]
                if unit == "kbit/s":
                    bwtmp *= 1000
                elif unit == "Mbit/s":
                    bwtmp *= (1000*1000)
                elif unit == "Gbit/s":
                    bwtmp *= (1000*1000*1000)
                bandwidth += bwtmp
            bandwidth_array.append(bandwidth)
        else:
            bandwidth = 0
    return max(bandwidth_array)


def Gettask(host):
    url = "http://%s/test.dd" % host
    p = Pool(processes=128)
    num=10
    i = 0
    for i in range(num):
        try:
            p.apply_async(Getdata, args = (str(url), '/dev/null', ), )
        except:
            print "url download fail"
    p.close()
    p.join()
    print "url %s subprocesses done." % url

if __name__=='__main__':
    if len(sys.argv) != 2:
        print len(sys.argv)
        print "Usage: %s <xldl-agent.py>  <host>" % sys.argv[0]
        sys.exit(2)
    host = sys.argv[1]
    #num = int(sys.argv[2])
    name=os.popen('uname -n').read().split('\n')[0]
    cmd="netstat -rn|grep ^0.0.0.0|grep UG|awk '{print $NF}'"
    (status,dev)=commands.getstatusoutput(cmd)
    if status==0:
        localip=get_localaddr(dev)
    else:
        print "get local nic dev fail"
    if localip == host:
        bw =get_localhost_bandwidth_max()
        bw=float(bw/1000/1000)
        print "hostname=%s argv.host %s ip= %s bandwidth=%s Mbit/s" %(name,host,localip,bw)
        print "do nothing..."
        sys.exit(0)
    localip_pre=localip.split('.')[0:3]
    sysarg_pre=host.split('.')[0:3]
    if localip_pre == sysarg_pre:
        print 'same lan network'
        sys.exit(2)

    times=2
    for i in range(times):
        Gettask(host)
