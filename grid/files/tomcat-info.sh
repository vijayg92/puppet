#!/bin/sh

docroot="/appl/stats/webdocs"
Adata=$docroot/`hostname`.txt

############ Tomcat Stats ###################
ATversion=`su - tomcat -c "sh /appl/tomcat/bin/version.sh" | grep "Server version:" | cut -d "/" -f2`
if ! [ "$ATversion" ] ; then
        echo "ATversion=?" >> $Adata
else
        echo "Tversion=$ATversion" >> $Adata
fi

for n in `seq 0 1`
do
Aok=`netstat -an | grep 8"$n"09 | grep LISTEN | grep -v grep`
if [ "$Aok" ] ; then
        echo "T"$n"status=1123uptest2004" >> $Adata
else
        echo "T"$n"status=DOWN" >> $Adata
fi
Atomcatcpu=`top -c -n1 -b | grep tomcat"$n" | grep -v grep | awk '{print $9}'`
if  [ "$Atomcatcpu" ] ; then
        echo "Atomcatcpu"$n"=$Atomcatcpu" >> $Adata
else
        echo "Atomcatcpu"$n"=?" >> $Adata
fi

n=`expr "$n" + 1`
done
#########################
