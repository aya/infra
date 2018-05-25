#!/bin/ash
set -euo pipefail
set -o errexit

trap 'kill -SIGQUIT $PID' INT

# Launch pdns_server
[ $# -eq 0 ] && /usr/local/sbin/pdns_recursor || exec "$@" &
PID=$! && wait
