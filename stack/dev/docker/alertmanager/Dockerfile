FROM quay.io/prometheus/alertmanager:latest
LABEL maintainer "jc.iacono.gm@gmail.com"

COPY config.tmpl /etc/alertmanager/config.tmpl
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD []
