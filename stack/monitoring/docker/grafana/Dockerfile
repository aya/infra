FROM grafana/grafana:latest
LABEL maintainer "jc.iacono.gm@gmail.com"

ARG AWS_ACCESS_KEY
ARG AWS_SECRET_KEY
ARG MYSQL_GRAFANA_USER
ARG MYSQL_GRAFANA_PASSWORD
ARG MYSQL_GRAFANA_DB

COPY config.ini /etc/grafana/config.ini
COPY dashboards /var/lib/grafana/dashboards
COPY provisioning /etc/grafana/provisioning

USER root

RUN sed 's@AWS_ACCESS_KEY@'"${AWS_ACCESS_KEY:-UNDEFINED}"'@g' /etc/grafana/provisioning/datasources/datasources.tmpl > /etc/grafana/provisioning/datasources/datasources.tmpl2
RUN sed 's@AWS_SECRET_KEY@'"${AWS_SECRET_KEY:-UNDEFINED}"'@g' /etc/grafana/provisioning/datasources/datasources.tmpl2 > /etc/grafana/provisioning/datasources/datasources.tmpl3
RUN sed 's@MYSQL_GRAFANA_USER@'"${MYSQL_GRAFANA_USER:-UNDEFINED}"'@g' /etc/grafana/provisioning/datasources/datasources.tmpl3 > /etc/grafana/provisioning/datasources/datasources.tmpl4
RUN sed 's@MYSQL_GRAFANA_PASSWORD@'"${MYSQL_GRAFANA_PASSWORD:-UNDEFINED}"'@g' /etc/grafana/provisioning/datasources/datasources.tmpl4 > /etc/grafana/provisioning/datasources/datasources.tmpl5
RUN sed 's@MYSQL_GRAFANA_DB@'"${MYSQL_GRAFANA_DB:-UNDEFINED}"'@g' /etc/grafana/provisioning/datasources/datasources.tmpl5 > /etc/grafana/provisioning/datasources/datasources.yml

USER grafana
