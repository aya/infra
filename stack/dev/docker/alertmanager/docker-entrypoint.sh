#!/bin/ash
set -euo pipefail
set -o errexit
set -x

trap 'kill -SIGQUIT $PID' INT

# Launch alertmanager by default, or paramater
[ $# -eq 0 ] && /bin/alertmanager --storage.path=/etc/alertmanager || exec "$@" &
PID=$! && wait
