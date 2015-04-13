#!/bin/bash
apt-get update 
apt-get -y upgrade
apt-get install -q -y vim wget curl nginx php5-fpm php5-cli php5-dev php5-mysql php5-curl php5-gd php5-mcrypt php5-sqlite php5-xmlrpc php5-xsl php5-common php5-intl php5-cli php-apc git mcrypt python-setuptools sudo cron

curl -sL https://deb.nodesource.com/setup | bash -
apt-get install -y nodejs npm

# Install composer
/bin/mkdir -p /opt/bin
/usr/bin/wget -N -P /opt/bin https://getcomposer.org/composer.phar
/bin/chmod +x /opt/bin/composer.phar

# Supervisor Config
/usr/bin/easy_install supervisor
/usr/bin/easy_install supervisor-stdout

unlink /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/orocrm /etc/nginx/sites-enabled/orocrm

