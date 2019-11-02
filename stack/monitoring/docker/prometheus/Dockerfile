FROM quay.io/prometheus/prometheus:latest
LABEL maintainer "jc.iacono.gm@gmail.com"

ARG MONITORING_PRIMARY_TARGETS_BLACKBOX
ARG MONITORING_SECONDARY_TARGETS_BLACKBOX

COPY prometheus.tmpl /etc/prometheus/prometheus.tmpl
COPY alert-rules.yml /etc/prometheus/alert-rules.yml

# Creating the config file.
# The last -e instruction cleans the file from quotes in the lists
RUN sed \
    -e 's|MONITORING_PRIMARY_TARGETS_BLACKBOX|'"        - ${MONITORING_PRIMARY_TARGETS_BLACKBOX// /\\n        - }"'|; s|MONITORING_SECONDARY_TARGETS_BLACKBOX|'"        - ${MONITORING_SECONDARY_TARGETS_BLACKBOX// /\\n        - }"'|' \
    /etc/prometheus/prometheus.tmpl > /etc/prometheus/prometheus.yml

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD []
