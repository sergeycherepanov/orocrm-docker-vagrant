#!/bin/bash

# Check is application alreasy installed
if [ ! -f /srv/orocrm.installed ]; then
   echo "OroCRM are not installed! Initiate installation..."
   touch /srv/orocrm.maintance
   if /opt/bin/install-orocrm.sh; then
     touch /srv/orocrm.installed
     rm /srv/orocrm.maintance
     echo "OroCRM Successfully installed!"
   else
     echo "Can't install OroCRM!"
     exit 1;
   fi 
   
fi

# start all the services
/usr/local/bin/supervisord -n

