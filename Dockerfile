FROM debian:7.8
MAINTAINER Sergey Cherepanov <scherepanov@magecore.com>

ENV DEBIAN_FRONTEND noninteractive

ADD ./bin/install-requirements.sh /opt/bin/install-requirements.sh
ADD ./bin/prepare-configs.sh /opt/bin/prepare-configs.sh
ADD ./bin/download-orocrm.sh /opt/bin/download-orocrm.sh

ADD ./bin/bootstrap.sh /opt/bin/bootstrap.sh
ADD ./bin/install-orocrm.sh /opt/bin/install-orocrm.sh

ADD ./conf/oro/parameters.yml /tmp/parameters.yml.tpl
# Fix error related to max file length in aufs
ADD ./OroRequirements.php /tmp/OroRequirements.php

ADD ./conf/nginx/crm.conf /etc/nginx/sites-available/orocrm
ADD ./conf/supervisord.conf /etc/supervisord.conf


RUN chmod 755 /opt/bin/bootstrap.sh && \
chmod 755 /opt/bin/install-requirements.sh && \
chmod 755 /opt/bin/prepare-configs.sh && \
chmod 755 /opt/bin/download-orocrm.sh && \
chmod 755 /opt/bin/install-orocrm.sh

RUN /opt/bin/install-requirements.sh

RUN /opt/bin/prepare-configs.sh
RUN /opt/bin/download-orocrm.sh

EXPOSE 80 8080

CMD ["/bin/bash", "/opt/bin/bootstrap.sh"]
