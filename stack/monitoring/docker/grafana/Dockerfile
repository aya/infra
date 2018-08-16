FROM grafana/grafana:latest
LABEL maintainer "jc.iacono.gm@gmail.com"

ARG AWS_ACCESS_KEY
ARG AWS_SECRET_KEY

COPY config.ini /etc/grafana/config.ini
COPY dashboards /var/lib/grafana/dashboards
COPY provisioning /etc/grafana/provisioning

USER root

RUN sed 's@AWS_ACCESS_KEY@'"${AWS_ACCESS_KEY:-UNDEFINED}"'@g' /etc/grafana/provisioning/datasources/datasources.tmpl > /etc/grafana/provisioning/datasources/datasources.tmpl2
RUN sed 's@AWS_SECRET_KEY@'"${AWS_SECRET_KEY:-UNDEFINED}"'@g' /etc/grafana/provisioning/datasources/datasources.tmpl2 > /etc/grafana/provisioning/datasources/datasources.yml

USER grafana
