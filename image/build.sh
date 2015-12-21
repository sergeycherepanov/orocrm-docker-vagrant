#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
USER="www-data"
GROUP="www-data"
MEMORY_LIMIT="1024"
UPLOAD_LIMIT="256"

apt-get -qy update
apt-get -qqy upgrade

# install base packages
apt-get install -qqy vim sudo wget curl php5-fpm php5-cli php5-dev \
php5-mysql php5-curl php5-gd php5-mcrypt php5-sqlite php5-xmlrpc \
php5-xsl php5-common php5-intl php5-cli php-apc git mcrypt \
python-setuptools procps

# Automatically instal the latest nginx
wget -O - http://nginx.org/keys/nginx_signing.key | sudo apt-key add -
echo "deb http://nginx.org/packages/mainline/ubuntu/ trusty nginx" >> /etc/apt/sources.list
echo "deb-src http://nginx.org/packages/mainline/ubuntu/ trusty nginx" >> /etc/apt/sources.list

apt-get -qy update
apt-get install -qqy --reinstall nginx

# install composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# install node.js
curl -sL https://deb.nodesource.com/setup | bash -
apt-get install -qqy nodejs

# install supervisor
easy_install supervisor
easy_install supervisor-stdout

# configure php cli
sed -i -e "s/;date.timezone\s=/date.timezone = UTC/g" /etc/php5/cli/php.ini
sed -i -e "s/short_open_tag\s=\s*.*/short_open_tag = Off/g" /etc/php5/cli/php.ini
sed -i -e "s/memory_limit\s=\s.*/memory_limit = ${MEMORY_LIMIT}M/g" /etc/php5/cli/php.ini
sed -i -e "s/max_execution_time\s=\s.*/max_execution_time = 0/g" /etc/php5/cli/php.ini

# configure php fpm
sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
sed -i -e "s/;date.timezone\s=/date.timezone = UTC/g" /etc/php5/fpm/php.ini
sed -i -e "s/short_open_tag\s=\s*.*/short_open_tag = Off/g" /etc/php5/fpm/php.ini

sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = ${UPLOAD_LIMIT}M/g" /etc/php5/fpm/php.ini
sed -i -e "s/memory_limit\s=\s.*/memory_limit = ${MEMORY_LIMIT}M/g" /etc/php5/fpm/php.ini
sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = ${UPLOAD_LIMIT}M/g" /etc/php5/fpm/php.ini
sed -i -e "s/max_execution_time\s=\s.*/max_execution_time = 300/g" /etc/php5/fpm/php.ini

# php-fpm config
sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php5/fpm/pool.d/www.conf
find /etc/php5/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

php5enmod mcrypt

# Configure nginx
sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size ${UPLOAD_LIMIT}m/" /etc/nginx/nginx.conf
echo "daemon off;" >> /etc/nginx/nginx.conf

