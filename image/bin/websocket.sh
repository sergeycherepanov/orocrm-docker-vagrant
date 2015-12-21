#!/bin/bash
/opt/bin/waitinstall.sh
exec /usr/bin/sudo -u www-data /var/www/app/console clank:server --env prod
