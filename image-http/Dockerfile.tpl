FROM %FROM%
MAINTAINER Sergey Cherepanov <sergey@cherepanov.org.ua>

COPY bin /opt/bin
COPY data/orocrm.conf      /etc/nginx/sites-enabled/orocrm.conf
COPY data/supervisord.conf /etc/supervisord.conf

VOLUME ["/var/www/app/cache", "/var/www/web/media", "/var/www/web/uploads", "/var/www/app/attachment"]

EXPOSE 80
CMD ["/bin/bash", "/opt/bin/run.sh"]
