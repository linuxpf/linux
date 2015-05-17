1.ssd: intel s3700  745.211 GB [0x5d26ceb0 Sectors]    BTTV344000L2800JGNSSDSC2BA800G3I       41Y8362 41Y8365IBM 5DV1NA33
fs:ext4

detail:
# cat /tmp/ssdtest/dd_test_1431695044.log 
###1 Write bs=4k
### write bs=4k bksize=4 count=10000000
10000000+0 records in
10000000+0 records out
40960000000 bytes (41 GB) copied, 559.712 s, 73.2 MB/s
###2 Write bs=64k
### write bs=64k bksize=64 count=625000
625000+0 records in
625000+0 records out
40960000000 bytes (41 GB) copied, 94.4672 s, 434 MB/s
###3 Write bs=128k
### write bs=128k bksize=128 count=312500
312500+0 records in
312500+0 records out
40960000000 bytes (41 GB) copied, 94.4679 s, 434 MB/s
###4 Write bs=1024k
### write bs=1024k bksize=1024 count=39062
39062+0 records in
39062+0 records out
40959475712 bytes (41 GB) copied, 94.2204 s, 435 MB/s
###5 Write bs=2048k
### write bs=2048k bksize=2048 count=19531
19531+0 records in
19531+0 records out
40959475712 bytes (41 GB) copied, 94.3388 s, 434 MB/s
###6 Write bs=4096k
### write bs=4096k bksize=4096 count=9765
9765+0 records in
9765+0 records out
40957378560 bytes (41 GB) copied, 94.3555 s, 434 MB/s
###7 Read test bs=4k=========
###read bs=4k count=10000000
10000000+0 records in
10000000+0 records out
40960000000 bytes (41 GB) copied, 451.723 s, 90.7 MB/s
###9 Read test bs=64k=========
###read bs=64k count=625000
625000+0 records in
625000+0 records out
40960000000 bytes (41 GB) copied, 130.372 s, 314 MB/s
###11 Read test bs=128k=========
###read bs=128k count=312500
312500+0 records in
312500+0 records out
40960000000 bytes (41 GB) copied, 110.857 s, 369 MB/s
###13 Read test bs=1024k=========
###read bs=1024k count=39062
39062+0 records in
39062+0 records out
40959475712 bytes (41 GB) copied, 95.9287 s, 427 MB/s
###15 Read test bs=2048k=========
###read bs=2048k count=19531
19531+0 records in
19531+0 records out
40959475712 bytes (41 GB) copied, 89.4719 s, 458 MB/s
###17 Read test bs=4096k=========
###read bs=4096k count=9765
9765+0 records in
9765+0 records out
40957378560 bytes (41 GB) copied, 86.2343 s, 475 MB/s
# cat /tmp/ssdtest/ramlog_dd_test_1431695044.log
###8 Ramdev read bs=4k=========
10000000+0 records in
10000000+0 records out
40960000000 bytes (41 GB) copied, 451.426 s, 90.7 MB/s
###Test read ramdevend bs=4k=========
###10 Ramdev read bs=64k=========
625000+0 records in
625000+0 records out
40960000000 bytes (41 GB) copied, 126.767 s, 323 MB/s
###Test read ramdevend bs=64k=========
###12 Ramdev read bs=128k=========
312500+0 records in
312500+0 records out
40960000000 bytes (41 GB) copied, 110.588 s, 370 MB/s
###Test read ramdevend bs=128k=========
###14 Ramdev read bs=1024k=========
39062+0 records in
39062+0 records out
40959475712 bytes (41 GB) copied, 95.4002 s, 429 MB/s
###Test read ramdevend bs=1024k=========
###16 Ramdev read bs=2048k=========
19531+0 records in
19531+0 records out
40959475712 bytes (41 GB) copied, 89.5026 s, 458 MB/s
###Test read ramdevend bs=2048k=========
###18 Ramdev read bs=4096k=========
9765+0 records in
9765+0 records out
40957378560 bytes (41 GB) copied, 85.6424 s, 478 MB/s
###Test read ramdevend bs=4096k=========
