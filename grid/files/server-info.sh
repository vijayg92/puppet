#!/bin/sh

docroot="/appl/stats/webdocs"
Adata=$docroot/`hostname`.txt

####### GENERAL SERVER INFO #################

echo "Ahostname=`hostname`" >> $Adata
echo "Aload=`cat /proc/loadavg  | awk '{print $2}'`" >> $Adata
echo "Auptime=`uptime | awk '{print $3}'`" >> $Adata
#echo "ACPU=`top -bn 2 -d 0.01 | grep '^Cpu.s' | tail -n1 | gawk '{print $2+$4+$6}'`" >> $Adata
echo "ACPU=`sar -u 1 | tail -1 | awk '{print $8}'`" >> $Adata
echo "Amemory=`free -m | head -3 | tail -1 | awk '{print $4}'`" >> $Adata
echo "Aapplused=`df -TH /appl | tail -n 1 | awk '{print $5}'`" >> $Adata
echo "Alogsused=`df -TH /logs | tail -n 1 | awk '{print $5}'`" >> $Adata

#############################################
