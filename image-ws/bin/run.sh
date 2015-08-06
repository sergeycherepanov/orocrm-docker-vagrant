#!/bin/bash
APP_ROOT="/var/www"

# update parameters yml
sudo -u www-data -E composer run-script post-install-cmd -n -d ${APP_ROOT};

# start all the services
sudo -u www-data /usr/bin/php /var/www/app/console clank:server --env prod

