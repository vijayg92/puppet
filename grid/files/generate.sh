#!/bin/bash

usage() {
        #Give instructions on how to use this script.
        echo "Usage: `basename $0`"
        echo "     stop - stops the collection service."
        echo "    start - start the collection service."
        exit 0
}

if [ -z $1 ] ; then
        usage
fi

pidfile="/appl/stats/scripts/pidfile"
pcheck=`ps -ef | /bin/grep "collections.sh" | /bin/grep -v /bin/grep | awk '{print $2}'`
#echo "The pcheck is $pcheck"

if [ "$1" = 'start' ]; then
        if [ -e  $pidfile ] && [ "$pcheck" ]; then
                echo " Collection Services are already running."
                exit
        elif [ -e  $pidfile ] && ! [ "$pcheck" ]; then
                echo " Collection Services not running. Old pidfile located."
                echo " Cleaning pidfile reference and starting collection services."
                rm -f $pidfile
                sh /appl/stats/scripts/collections.sh &
                echo $! > $pidfile
        elif ! [ -e  $pidfile ] && [ "$pcheck" ]; then
                echo " Collection Services are already running. No pidfile located."
                echo " Creating pidfile."
                echo $pcheck > $pidfile
        else
                sh /appl/stats/scripts/collections.sh &
                echo $! > $pidfile
        fi
fi
if [ "$1" = 'stop' ]; then
        if [ -e $pidfile ] && [ "$pcheck" ]; then
                kill -9 `cat $pidfile`
                rm -f $pidfile
                echo " Collection Services stopped."
        elif [ -e  $pidfile ] && ! [ "$pcheck" ]; then
                echo " Collection Services not running."
                echo "Deleting pidfile."
                rm -f $pidfile
        elif ! [ -e  $pidfile ] && [ "$pcheck" ]; then
                echo " No pidfile located."
                echo " Stopping by force."
                kill -9 $pcheck
        else
                echo " Not running."
        fi
fi
