#!/bin/bash

/opt/bin/waitinstall.sh
/opt/bin/wrapoutput.sh app:websocket "sudo -u www-data /usr/bin/php /var/www/app/console clank:server --env prod"
