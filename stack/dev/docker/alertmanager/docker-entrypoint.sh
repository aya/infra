#!/bin/ash
set -euo pipefail
set -o errexit
set -x

trap 'kill -SIGQUIT $PID' INT

sed 's@SLACK_WEBHOOK_ID@'"${SLACK_WEBHOOK_ID:-UNDEFINED}"'@g' /etc/alertmanager/config.tmpl > /etc/alertmanager/alertmanager.yml


# Launch alertmanager by default, or paramater
[ $# -eq 0 ] && /bin/alertmanager --storage.path=/etc/alertmanager || exec "$@" &
PID=$! && wait
