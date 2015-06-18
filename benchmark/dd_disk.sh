#!/bin/bash
#dd to all disk
mountpoint=`/bin/df |awk '/data/{print $NF}'`
check(){
[ `ps -ef |grep dd |grep -v grep|wc -l` -gt 24 ] && sleep 70

}
everydisk(){
for i in `seq 1 10000`;do
    {
    filename=`head -c 500 /dev/urandom | tr -dc '0-9' | head -c 12`
    size=`head -c 500 /dev/urandom | tr -dc '1-9' | head -c 2`
    size=$((size+50))
    dd if=/dev/zero   of=${point}/${filename}.bat bs=1024k count=$size
    #dd if=/dev/urandom   of=${point}/${filename}.bat bs=1024k count=$size
    }&
    check
done
}
for point in $mountpoint; do
    echo $point
    everydisk &
done
#for i in `ls /data8`; do echo "ln -sf /data8/$i ."; done |sh
