#!/bin/bash
docroot="/appl/stats/webdocs"
scripts="/root/scripts"
Adata=$docroot/`hostname`.txt

`cat /dev/null > $Adata`
sleep 2;

sh $scripts/server-info.sh
sh $scripts/apache-info.sh
sh $scripts/tomcat-info.sh
#sh $scripts/node-info.sh
#sh $scripts/php-info.sh
