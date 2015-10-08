#!/bin/bash
until [ ! -f /var/www/app/config/parameters.yml ] || [ 0 -lt `cat /var/www/app/config/parameters.yml | grep ".*installed:\s*[\']\{0,1\}[a-zA-Z0-9\:\+\-]\{1,\}[\']\{0,1\}" | wc -l` ]
do
    sleep 2;
done
