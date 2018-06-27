FROM quay.io/prometheus/prometheus:latest
LABEL maintainer "jc.iacono.gm@gmail.com"

COPY prometheus.tmpl /etc/prometheus/prometheus.tmpl
COPY alert-rules.yml /prometheus/alert-rules.yml
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD []

