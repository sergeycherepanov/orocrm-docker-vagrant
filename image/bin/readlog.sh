#!/bin/bash
until [ -f $1 ]
do
    sleep 5
done

if [ ! -z $2 ]; then
    tail -f $1 | awk '{print "['$2'] " $0}'
else
    tail -f $1
fi
