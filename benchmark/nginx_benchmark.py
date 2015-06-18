#!/usr/bin/env python

import time
import sys
import os
import errno
import pycurl
from cStringIO import StringIO
from multiprocessing import Pool
import signal
import random

def getdata(url):
    #print url
    head = ['User-Agent:Mozilla/5.0 (Windows NT 5.1; rv:25.0) Gecko/20100101 Firefox/24.3', 'Cookie: gdriveid=4B3AA23F722CEACB20719A7AD77E28D3']
    handle = pycurl.Curl()
    handle.setopt(pycurl.URL, url)
    handle.setopt(pycurl.HTTPHEADER,  head)
    handle.setopt(pycurl.TIMEOUT, 30)
    handle.setopt(pycurl.FOLLOWLOCATION, True)
    handle.perform()
    http_code = handle.getinfo(pycurl.HTTP_CODE)
    if http_code == "200":
        speed = handle.getinfo(pycurl.SPEED_DOWNLOAD)
        print url, http_code, speed/1024
    else:
        print url, http_code
    #f=StringIO(content)
    #the_page = gzip.GzipFile(fileobj=f)
    #return content

def main():
    while True:
        pool = Pool(processes=256)
        j = 1
        while j < 256:
            j += 1
            url = "http://10.70.1.102/%s.dat" % random.randint(1, 4568)
            print url
            pool.apply_async(getdata, args = (str(url), ), )
        #pool.close()

        pool.close()
        pool.join()


def timeout(signum, frame):
    pass

#SIGALRM is only usable on a unix platform
signal.signal(signal.SIGALRM, timeout)

#change 5 to however many seconds you need
signal.alarm(15)

main()

