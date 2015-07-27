FROM %FROM%

COPY bin /opt/bin
COPY data/* /tmp/

RUN chmod +x /opt/bin/build.sh && sleep 1 && /opt/bin/build.sh \
&& sleep 1 && rm -f /opt/bin/build.sh

CMD ["/bin/bash", "/opt/bin/run.sh"]
