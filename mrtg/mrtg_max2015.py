#!/usr/bin/env python
#*- coding:utf-8 -*-
__author__ = 'Mpf(meipengfei@xunlei.com)'
#modify 20150407
import os,getopt, sys
import time
#open mrtg log
"""
"""

def last_month(ostamp):
    nowtime=time.localtime()
    nowtime_year,last_month=nowtime.tm_year,(nowtime.tm_mon-1)
    appo_time=time.localtime(int(ostamp))
    appo_time_year,appo_time_month=appo_time.tm_year,appo_time.tm_mon
    if (int(nowtime_year) == int(appo_time_year) and int(last_month) == int(appo_time_month)):
        return True
    else:
        return False

def getlog(path, start=1, end=600):
    result_in,result_out,output= {},{},{}
    num = 0
    f=open(path,'r')
    for line in f.readlines():
        if(len(line) == 0 or line[0] == '#'):
            continue
        if(num >=start and num <= end):
            fields = line.split()
            result_in[int(fields[0])] = int(fields[1])
            result_out[int(fields[0])] = int(fields[2])
        num+=1
    f.close()
    output['in'] = result_in
    output['out'] = result_out
    return output

def getlog_monthly(path):
    result_in,result_out,output = {},{},{}
    num = 0
    f=open(path,'r')
    for line in f.readlines():
        if(len(line) == 0 or line[0] == '#'):
            continue
        fields = line.split()
        Test=last_month(int(fields[0]))
        if Test:
            result_in[int(fields[0])] = int(fields[1])
            result_out[int(fields[0])] = int(fields[2])
        num+=1
    f.close()
    output['in'] = result_in
    output['out'] = result_out
    return output

def _max3(result,path,content='',Format=None,Exchange=True):
    in_max,out_max,tmp = [],[],[]
    in_max=sorted(result['in'].iteritems(), key=lambda d:d[1], reverse = True)[0:3]
    out_max=sorted(result['out'].iteritems(), key=lambda d:d[1], reverse = True)[0:3]
    tmp = in_max + out_max
    #content=''
    w=open(path,'a')
    for key in range(len(tmp)):
        for j in range(len(tmp[key])):
            if j <1:
                if Format:
                    content= content + str(time.strftime('%Y-%m-%d',time.localtime(tmp[key][j]))) +':'
                else:
                    content= content + str(tmp[key][j]) +':'
            else:
                if Exchange:
                    content = content + str(int(tmp[key][j])*8/1000/1000) + ' '
                else:
                    content = content + str(int(tmp[key][j])) + ' '
    #print "content=%s" %content
    content=content+'\n'
    w.writelines(content)
    #w.writelines('\n')
    w.close()
    #return output
#get 33 days data
def _colle_month(path):
    result_in,result_out,output = {},{},{}
    num = 0
    f=open(path,'r')
    for line in f.readlines():
        fields = line.split()
        Test=last_month(int(fields[0]))
        if Test:
            result_in[int(fields[0])] = int(fields[1])
            result_out[int(fields[0])] = int(fields[2])
        num+=1
    f.close()
    output['in'] = result_in
    output['out'] = result_out
    return output

#save all daily vaulue log to redirect_path file
def getlog_redirect(path,redirect_path,start=1, end=600):
    result_in,result_out,output= {},{},{}
    num = 0
    f=open(path,'r')
    wr=open(redirect_path,'a')
    content=''
    for line in f.readlines():
        if(len(line) == 0 or line[0] == '#'):
            continue
        if(num >=start and num <= end):
            fields = line.split()
            result_in[int(fields[0])] = int(fields[1])
            result_out[int(fields[0])] = int(fields[2])
            content=content+line
            
        num+=1
    f.close()
    wr.writelines(content) 
    wr.close()
    output['in'] = result_in
    output['out'] = result_out
    return output

def main(argv):
    output_dir='/usr/local/check_mrtg/log/mrtg_output'
    base_dir='/usr/local/mrtg/htdocs'
    tmp_dir='/usr/local/check_mrtg/data'
    filename= argv[0]
    swith_name=os.path.basename(filename).split('.log')[0] + ': '
    basename = os.path.basename(filename)
    #swith_name=filename.split('.log')[0] + ': '
    if (argv[1]) =='daily':
        #result=getlog(os.path.join(base_dir,filename), 1 , 600)
        #_max3(result,os.path.join(tmp_dir,os.path.basename(filename)))
        getlog_redirect(os.path.join(base_dir,filename),os.path.join(tmp_dir,os.path.basename(filename)), 1 , 600)
    elif (argv[1])=='monthly':
        result=getlog_monthly(os.path.join(base_dir,filename))
        outfile = 'monthly-output-' + time.strftime('%Y-%m-%d',time.localtime(time.time())) +'.log'
        _max3(result,os.path.join(output_dir,outfile),content=swith_name,Format=True)
    elif (argv[1])=='33day':
        result=_colle_month(os.path.join(tmp_dir,basename))
        outfile = '33day-output-' + time.strftime('%Y-%m-%d',time.localtime(time.time())) +'.log'
        _max3(result,os.path.join(output_dir,outfile),content=swith_name,Format=True)
    else:
        print "Unknown %s argument!" %(argv[1])
        sys.exit(2)
        
if __name__ == "__main__":
    if len(sys.argv[1:]) !=2:
        print "Usage: %s <mrtglog_filename> <daily|monthly|33day>" % sys.argv[0]
        sys.exit(2)
    else:
        main([sys.argv[1],sys.argv[2]])
