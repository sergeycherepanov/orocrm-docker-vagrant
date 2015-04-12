FROM debian:7.8
MAINTAINER Sergey Cherepanov <scherepanov@magecore.com>

ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN apt-get update && apt-get -y upgrade && apt-get install -q -y vim wget curl nginx php5-fpm php5-cli php5-dev php5-mysql php5-curl php5-gd php5-mcrypt php5-sqlite php5-xmlrpc php5-xsl php5-common php5-intl php5-cli php-apc git mcrypt python-setuptools sudo cron

RUN curl -sL https://deb.nodesource.com/setup | bash -
RUN apt-get install -y nodejs npm

# nginx config
RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
RUN sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# nginx site conf
ADD ./conf/nginx/crm.conf /etc/nginx/sites-available/default

# php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/;date.timezone\s=/date.timezone = UTC/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/memory_limit\s=\s.*/memory_limit = 512M/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/short_open_tag\s=\s*.*/short_open_tag = Off/g" /etc/php5/fpm/php.ini

# php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/cli/php.ini
RUN sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php5/cli/php.ini
RUN sed -i -e "s/;date.timezone\s=/date.timezone = UTC/g" /etc/php5/cli/php.ini
RUN sed -i -e "s/memory_limit\s=\s.*/memory_limit = 512M/g" /etc/php5/cli/php.ini
RUN sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php5/cli/php.ini
RUN sed -i -e "s/short_open_tag\s=\s*.*/short_open_tag = Off/g" /etc/php5/cli/php.ini


RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php5/fpm/pool.d/www.conf
RUN find /etc/php5/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

# Install composer
RUN /bin/mkdir -p /opt/bin
RUN /usr/bin/wget -N -P /opt/bin https://getcomposer.org/composer.phar
RUN /bin/chmod +x /opt/bin/composer.phar

# Supervisor Config
RUN /usr/bin/easy_install supervisor
RUN /usr/bin/easy_install supervisor-stdout
ADD ./conf/supervisord.conf /etc/supervisord.conf

# Install OroCRM
RUN /usr/bin/wget -O /tmp/crm-application-1.6.1.tar.gz -N -P /tmp https://github.com/orocrm/crm-application/archive/1.6.1.tar.gz
RUN /bin/tar -zxf /tmp/crm-application-1.6.1.tar.gz -C /tmp && mv /tmp/crm-application-1.6.1 /var/www
RUN /opt/bin/composer.phar install -d /var/www
RUN chown www-data:www-data -R /var/www

# Fix error related to max file length in aufs
ADD ./OroRequirements.php /var/www/app/OroRequirements.php

ADD ./conf/oro/parameters.yml /var/www/app/config/parameters.yml.tpl

ADD ./bin/bootstrap.sh /opt/bin/bootstrap.sh
ADD ./bin/install.sh /opt/bin/install.sh
RUN chmod 755 /opt/bin/install.sh
RUN chmod 755 /opt/bin/bootstrap.sh


EXPOSE 80
EXPOSE 8080

CMD ["/bin/bash", "/opt/bin/bootstrap.sh"]
