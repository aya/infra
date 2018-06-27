FROM quay.io/prometheus/alertmanager:latest
LABEL maintainer "jc.iacono.gm@gmail.com"

ARG SLACK_WEBHOOK_ID

COPY config.tmpl /etc/alertmanager/config.tmpl
COPY docker-entrypoint.sh /

RUN sed 's@SLACK_WEBHOOK_ID@'"${SLACK_WEBHOOK_ID:-UNDEFINED}"'@g' /etc/alertmanager/config.tmpl > /etc/alertmanager/alertmanager.yml

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD []
