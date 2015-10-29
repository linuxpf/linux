#!/bin/bash

#rename gfs name
rootdir="/yourpath/"
dirp1=`gfs -ls $rootdir/awk '{print $NF}'`
for dir1  in ${dirp1};do
    pathp1=`echo "${rootdir}/${dir1}"`
    if [ `echo "$dir1"|egrep '[a-z]'|wc -l` -gt 0 ]; then
        upp_dir1=`echo $dir1|tr "[:lower:]" "[:upper:]"`
        upp_path1=`echo "${rootdir}/${upp_dir1}"`
        echo "pathp1=${pathp1} upp_dir=${upp_path1}"
        [ -z ${upp_path1} ] && echo "upp_path1=null" && exit 1
        echo "gfs -mv ${pathp1} ${upp_path1}"
        gfs -mv ${pathp1} ${upp_path1}
        re=$?
        if [ $re -ne 0 ];then
            echo "gfs change dir success"
            gfs -ls ${upp_path1}
        fi
    fi
    
done
