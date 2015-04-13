#!/bin/bash

# Download OroCRM
/usr/bin/wget -O /tmp/crm-application-1.6.1.tar.gz -N -P /tmp https://github.com/orocrm/crm-application/archive/1.6.1.tar.gz
/bin/tar -zxf /tmp/crm-application-1.6.1.tar.gz -C /tmp 
/bin/mv /tmp/crm-application-1.6.1 /var/www 
/bin/rm /tmp/crm-application-1.6.1.tar.gz
/bin/chmod +x /opt/bin/composer.phar
/usr/bin/php /opt/bin/composer.phar install -d /var/www
/bin/mv /tmp/parameters.yml.tpl /var/www/app/config/parameters.yml.tpl
/bin/mv /tmp/OroRequirements.php /var/www/app/OroRequirements.php
/bin/chown www-data:www-data -R /var/www

