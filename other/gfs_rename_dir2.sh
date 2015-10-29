#!/bin/bash

#
rootdir="/yourpath/g"
dirp1=`gfs -ls /yourpath/g/|awk '{print $NF}'`
for dir1  in ${dirp1};do
    pathp1=`echo "${rootdir}/${dir1}"`

    dirp2=`gfs -ls /yourpath/g/${dir1}/|awk '{print $NF}'`
    for dir2 in ${dirp2};do
        pathp2=`echo "${pathp1}/${dir2}"`
    if [ `echo "$dir2"|egrep '[a-z]'|wc -l` -gt 0 ]; then
        upp_dir2=`echo ${dir2}|tr "[:lower:]" "[:upper:]"`
        upp_path2=`echo "${pathp1}/${upp_dir2}"`

        echo "pathp2=${pathp2} upp_dir2=${upp_path2}"
        [ -z ${upp_path2} ] && echo "upp_path2=null" && exit 1
        echo "gfs -mv ${pathp2} ${upp_path2}"
        gfs -mv ${pathp2} ${upp_path2}
        re=$?
        if [ $re -eq 0 ];then
            echo "gfs change dir success"
            #gfs -ls ${upp_path1}
        else
            echo "gfs change dir ${pathp2} fail"
        fi
    fi
    done
done
