FROM %FROM%
MAINTAINER Sergey Cherepanov <sergey@cherepanov.org.ua>

COPY bin /opt/bin

VOLUME ["/var/www/app/cache", "/var/www/web/media", "/var/www/web/uploads", "/var/www/app/attachment"]

EXPOSE 8080
CMD ["/bin/bash", "/opt/bin/run.sh"]
