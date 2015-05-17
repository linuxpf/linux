#add mrtg_3max
2 0 1 * * /usr/local/check_mrtg/bin/mrtg-3max2015.sh monthly >/dev/null 2>&1 & 
30 0 1 * * /usr/local/check_mrtg/bin/mrtg-3max2015.sh 33day >/dev/null 2>&1 & 
0 0 * * * /usr/local/check_mrtg/bin/mrtg-3max2015.sh daily >/dev/null 2>&1 & 
