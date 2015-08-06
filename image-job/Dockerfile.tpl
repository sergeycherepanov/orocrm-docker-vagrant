FROM %FROM%
MAINTAINER Sergey Cherepanov <sergey@cherepanov.org.ua>

COPY bin /opt/bin
COPY data/supervisord.conf /etc/supervisord.conf

VOLUME ["/var/www/app/cache", "/var/www/web/media", "/var/www/web/uploads", "/var/www/app/attachment"]

CMD ["/bin/bash", "/opt/bin/run.sh"]
