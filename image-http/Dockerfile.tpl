FROM %FROM%
MAINTAINER Sergey Cherepanov <sergey@cherepanov.org.ua>

COPY bin /opt/bin
COPY data/* /tmp/

RUN chmod +x /opt/bin/build.sh && sleep 1 && /opt/bin/build.sh \
&& sleep 1 && rm -f /opt/bin/build.sh

VOLUME ["/var/www/app/cache", "/var/www/web/media", "/var/www/web/uploads", "/var/www/app/attachment"]

EXPOSE 80
CMD ["/bin/bash", "/opt/bin/run.sh"]
