FROM quay.io/prometheus/prometheus:latest
LABEL maintainer "jc.iacono.gm@gmail.com"

ARG LATENCYAT_TOKEN
ARG MONITORING_TARGETS_BLACKBOX
ARG MONITORING_TARGETS_LATENCYAT


COPY prometheus.tmpl /etc/prometheus/prometheus.tmpl
COPY alert-rules.yml /etc/prometheus/alert-rules.yml

# Creating the config file.
# The last -e instruction cleans the file from quotes in the lists
RUN sed -e 's|TOKEN_LATENCYAT|'"${LATENCYAT_TOKEN:-UNDEFINED}"'|g' \
-e 's|MONITORING_TARGETS_BLACKBOX|'"        - ${MONITORING_TARGETS_BLACKBOX// /\\n        - }"'|' \
-e 's|MONITORING_TARGETS_LATENCYAT|'"        - ${MONITORING_TARGETS_LATENCYAT// /\\n        - }"'|' \
-e 's/\"//g' /etc/prometheus/prometheus.tmpl > /etc/prometheus/prometheus.yml

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD []

