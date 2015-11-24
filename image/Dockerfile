FROM ubuntu:14.04

COPY source                   /var/www
COPY bin                      /opt/bin
COPY data/OroRequirements.php /tmp/OroRequirements.php

RUN chmod +x /opt/bin/* && sleep 1 && if /opt/bin/build.sh; then \
sleep 1 && rm -f /opt/bin/build.sh; \
else exit 1; fi \
&& rm /etc/nginx/conf.d/default.conf

COPY data/nginx.conf          /etc/nginx/nginx.conf
COPY data/nginx-orocrm.conf   /etc/nginx/sites-enabled/orocrm.conf
COPY data/supervisord.conf    /etc/supervisord.conf

RUN mkdir -p /var/www/app/cache && chown www-data:www-data /var/www/app/cache && \
mkdir -p /var/www/web/media && chown www-data:www-data /var/www/web/media && \
mkdir -p /var/www/web/uploads && chown www-data:www-data /var/www/web/uploads && \
mkdir -p /var/www/app/attachment && chown www-data:www-data /var/www/app/attachment

VOLUME ["/var/www/app/cache", "/var/www/web/media", "/var/www/web/uploads", "/var/www/app/attachment"]

EXPOSE 80

CMD ["/bin/bash", "/opt/bin/run.sh"]
