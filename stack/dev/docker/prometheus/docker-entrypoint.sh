#!/bin/ash
set -euo pipefail
set -o errexit
set -x

trap 'kill -SIGQUIT $PID' INT

sed 's@TOKEN_LATENCYAT@'"${LATENCYAT_TOKEN:-UNDEFINED}"'@g' /etc/prometheus/prometheus.tmpl > /prometheus/prometheus.yml

# Launch alertmanager by default, or paramater
[ $# -eq 0 ] && /bin/prometheus || exec "$@" &
PID=$! && wait

