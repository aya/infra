#!/bin/sh

cat > /tmp/setup-answers <<EOF
KEYMAPOPTS="fr fr"
HOSTNAMEOPTS="-n $HOSTNAME"
INTERFACESOPTS="auto lo
iface lo inet loopback
auto eth0
iface eth0 inet dhcp
      hostname $HOSTNAME
"
DNSOPTS="-n 8.8.8.8"
TIMEZONEOPTS="-z Europe/Paris"
PROXYOPTS="none"
APKREPOSOPTS="http://dl-cdn.alpinelinux.org/alpine/v3.7/main"
SSHDOPTS="-c openssh"
NTPOPTS="-c openntpd"
DISKOPTS="-s 0 -m sys /dev/vda"
EOF

setup-alpine -f /tmp/setup-answers <<EOF
$PASSWORD
$PASSWORD
y
EOF

