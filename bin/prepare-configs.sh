#!/bin/bash

# nginx config
sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf
echo "daemon off;" >> /etc/nginx/nginx.conf

# php-fpm config
sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php5/fpm/php.ini
sed -i -e "s/;date.timezone\s=/date.timezone = UTC/g" /etc/php5/fpm/php.ini
sed -i -e "s/memory_limit\s=\s.*/memory_limit = 512M/g" /etc/php5/fpm/php.ini
sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php5/fpm/php.ini
sed -i -e "s/short_open_tag\s=\s*.*/short_open_tag = Off/g" /etc/php5/fpm/php.ini

# php-fpm config
sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/cli/php.ini
sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php5/cli/php.ini
sed -i -e "s/;date.timezone\s=/date.timezone = UTC/g" /etc/php5/cli/php.ini
sed -i -e "s/memory_limit\s=\s.*/memory_limit = 512M/g" /etc/php5/cli/php.ini
sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php5/cli/php.ini
sed -i -e "s/short_open_tag\s=\s*.*/short_open_tag = Off/g" /etc/php5/cli/php.ini


sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php5/fpm/pool.d/www.conf
find /etc/php5/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

