#!/bin/bash

#
rootdir="/yourpath"

#p1
dirp1=`gfs -ls /yourpath/|awk '{print $NF}'`
for dir1  in ${dirp1};do
    pathp1=`echo "${rootdir}/${dir1}"`

    #p2
    dirp2=`gfs -ls /yourpath/${dir1}/|awk '{print $NF}'`
    for dir2 in ${dirp2};do
        pathp2=`echo "${pathp1}/${dir2}"`
        
        #file
        filenamelist=`gfs -ls /yourpath/${dir1}/${dir2}/|awk '{print $NF}'`
        for filename in ${filenamelist};do
            hz_file=`echo $filename|awk -F".flv" '{print $2 }'`
            pre_file=`echo $filename|awk -F".flv" '{print $1 }'`

            if [ `echo $pre_file|grep '[a-z]'|wc -l` -gt 0 ]; then
                upp_pre_file=`echo ${pre_file}|tr "[:lower:]" "[:upper:]"` 

                oldfile_fullpath="${rootdir}/${dir1}/${dir2}/${filename}"
                newfile_fullpath="${rootdir}/${dir1}/${dir2}/${upp_pre_file}.flv"

                echo "oldfile_fullpath=${oldfile_fullpath} newfile_fullpath=${newfile_fullpath}"
                [ -z ${newfile_fullpath} ] && echo "newfile_fullpath=null" && exit 1
                echo "gfs ${oldfile_fullpath} ${newfile_fullpath}"
                gfs -mv ${oldfile_fullpath} ${newfile_fullpath}
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
done
