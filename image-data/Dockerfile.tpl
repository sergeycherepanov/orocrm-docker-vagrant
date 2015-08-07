FROM %FROM%
MAINTAINER Sergey Cherepanov <sergey@cherepanov.org.ua>

RUN mkdir -p /var/www/app/cache && chown www-data:www-data /var/www/app/cache && \
mkdir -p /var/www/web/media && chown www-data:www-data /var/www/web/media && \
mkdir -p /var/www/web/uploads && chown www-data:www-data /var/www/web/uploads && \
mkdir -p /var/www/app/attachment && chown www-data:www-data /var/www/app/attachment

VOLUME ["/var/www/app/cache", "/var/www/web/media", "/var/www/web/uploads", "/var/www/app/attachment"]

