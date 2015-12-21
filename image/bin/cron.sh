#!/bin/bash
/opt/bin/waitinstall.sh
/opt/bin/listener.php /var/log/oro-cron.log /var/www/app/console oro:cron --env prod
