FROM ubuntu:14.04
USER root
COPY build.sh /usr/local/bin/bap-base-system-build

RUN chmod +x /usr/local/bin/bap-base-system-build \
&& sleep 1 \
&& bap-base-system-build || exit 1 \
&& rm /etc/nginx/conf.d/default.conf \
&& rm -rf /var/www \
&& mkdir -p /srv/app-data \
&& chown www-data:www-data /srv/app-data

COPY data/nginx.conf          /etc/nginx/nginx.conf
COPY data/nginx-orocrm.conf   /etc/nginx/sites-enabled/orocrm.conf
COPY data/supervisord.conf    /etc/supervisord.conf

EXPOSE 80 8080

VOLUME ["/srv/app-data"]
