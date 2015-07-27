FROM ubuntu:14.04
MAINTAINER Sergey Cherepanov <sergey@cherepanov.org.ua>

COPY source /var/www
COPY bin /opt/bin
COPY data/* /tmp/

RUN chmod +x /opt/bin/* && sleep 1 && if /opt/bin/build.sh; then \
sleep 1 && rm -f /opt/bin/build.sh; \
else exit 1; fi
