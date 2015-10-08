#!/bin/bash
APP_ROOT="/var/www"

# update parameters yml
sudo -u www-data -E composer run-script post-install-cmd -n -d ${APP_ROOT};

/bin/bash /opt/bin/wait-install.sh

# start all the services
exec /usr/local/bin/supervisord -n

