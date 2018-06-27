FROM quay.io/prometheus/prometheus:latest
LABEL maintainer "jc.iacono.gm@gmail.com"

ARG LATENCYAT_TOKEN

COPY prometheus.tmpl /etc/prometheus/prometheus.tmpl
COPY alert-rules.yml /etc/prometheus/alert-rules.yml

RUN sed 's@TOKEN_LATENCYAT@'"${LATENCYAT_TOKEN:-UNDEFINED}"'@g' /etc/prometheus/prometheus.tmpl > /etc/prometheus/prometheus.yml

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD []

