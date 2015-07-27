#!/bin/bash
echo "Building oro/crm-debian-base image..."
export DEBIAN_FRONTEND=noninteractive

APP_ROOT="/var/www"
USER="www-data"
GROUP="www-data"
MEMORY_LIMIT="512"
UPLOAD_LIMIT="128"


apt-get update
apt-get -y upgrade

# install software
apt-get install -q -y vim sudo wget curl php5-cli php5-dev \
php5-mysql php5-curl php5-gd php5-mcrypt php5-sqlite php5-xmlrpc \
php5-xsl php5-common php5-intl php5-cli php-apc git mcrypt \
python-setuptools procps mysql-client php5-fpm nginx

php5enmod mcrypt

# install node.js
curl -sL https://deb.nodesource.com/setup | bash -
apt-get install -y nodejs

# install supervisor
easy_install supervisor
easy_install supervisor-stdout
easy_install pip
pip install  supervisor-logging


# nginx config
sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size ${UPLOAD_LIMIT}m/" /etc/nginx/nginx.conf
echo "daemon off;" >> /etc/nginx/nginx.conf

unlink /etc/nginx/sites-enabled/default
mv /tmp/orocrm.conf /etc/nginx/sites-available/orocrm.conf
ln -s /etc/nginx/sites-available/orocrm.conf /etc/nginx/sites-enabled/orocrm.conf

# php-cli config
sed -i -e "s/;date.timezone\s=/date.timezone = UTC/g" /etc/php5/cli/php.ini
sed -i -e "s/short_open_tag\s=\s*.*/short_open_tag = Off/g" /etc/php5/cli/php.ini
sed -i -e "s/memory_limit\s=\s.*/memory_limit = ${MEMORY_LIMIT}M/g" /etc/php5/cli/php.ini
sed -i -e "s/max_execution_time\s=\s.*/max_execution_time = 0/g" /etc/php5/cli/php.ini

# php config
sed -i -e "s/;date.timezone\s=/date.timezone = UTC/g" /etc/php5/fpm/php.ini
sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
sed -i -e "s/short_open_tag\s=\s*.*/short_open_tag = Off/g" /etc/php5/fpm/php.ini
sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = ${UPLOAD_LIMIT}M/g" /etc/php5/fpm/php.ini
sed -i -e "s/memory_limit\s=\s.*/memory_limit = ${MEMORY_LIMIT}M/g" /etc/php5/fpm/php.ini
sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = ${UPLOAD_LIMIT}M/g" /etc/php5/fpm/php.ini
sed -i -e "s/max_execution_time\s=\s.*/max_execution_time = 300/g" /etc/php5/fpm/php.ini

# php-fpm config
sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php5/fpm/pool.d/www.conf
find /etc/php5/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

touch /var/log/php5-fpm.log
touch /var/log/nginx/error.log

# install composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

chown ${USER} -R ${APP_ROOT}
#sudo -u ${USER} composer install --prefer-source -d ${APP_ROOT}
sudo -u ${USER} composer install --prefer-dist --optimize-autoloader -d ${APP_ROOT}

#configs and dirty fixes
mv /tmp/config.yml          ${APP_ROOT}/app/config/config.yml
mv /tmp/parameters.yml      ${APP_ROOT}/app/config/parameters.yml
mv /tmp/OroRequirements.php ${APP_ROOT}/app/OroRequirements.php

chown ${USER}:${GROUP} ${APP_ROOT}/app/config/config.yml
chown ${USER}:${GROUP} ${APP_ROOT}/app/config/parameters.yml
chown ${USER}:${GROUP} ${APP_ROOT}/app/OroRequirements.php

exit 0



