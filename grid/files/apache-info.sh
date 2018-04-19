#!/bin/sh
docroot="/appl/stats/webdocs"
Adata=$docroot/`hostname`.txt
IPS=( 3.32.216.59 3.32.216.58 )

####### Apache SERVER INFO #################
Aversion=`apachectl -v | head -n1 | awk '{print $3}' | cut -d "/" -f2`
if ! [ "$Aversion" ] ; then
        echo "Aversion=?" >> $Adata
else
        echo "Aversion=$Aversion" >> $Adata
fi
n=0
for apache in ${IPS[@]}
	do
Aok=`netstat -ntlp | grep "$apache:80 "`
if [ "$Aok" ] ; then
	 echo "A"$n"status=1123uptest2004" >> $Adata
else
	 echo "A"$n"status=DOWN" >> $Adata
fi

Aconnections=`netstat -antlp | grep "$apache:80 " | grep -v grep | wc -l`
if ! [ "$Aconnections" ] ; then
	echo "A"$n"conns=?" >> $Adata
else
	echo "A"$n"conns=$Aconnections" >> $Adata
fi

Aload=`top -c -n1 -b  | grep apache"$n" | grep -v grep | awk '{print $9}' | (sed 's/^/x+=/'; echo x) | bc`
if ! [ "$Aload" ] ; then
	echo "A"$n"cpu=?" >> $Adata
else
	echo "A"$n"cpu=$Aload" >> $Adata
fi

Aprocesses=`ps -eLf | grep httpd | grep apache"$n" | grep -v grep | wc -l`
if ! [ "$Aprocesses" ] ; then
	echo "A"$n"threads=?" >> $Adata
else
	echo "A"$n"threads=$Aprocesses" >> $Adata
fi

Amemory=`ps aux | grep apache$n | grep -v grep  | awk '{ m+=$6 } END { print m }'`
if ! [ "$Amemory" ] ; then
	echo "Amemapache"$n"=?" >> $Adata
else

Amemorymb=$(echo "scale=2; $Amemory/1024" | bc)
	echo "Amemapache"$n"=$Amemorymb" >> $Adata
fi

n=`expr "$n" + 1`

done

###############################################
