#!/bin/sh -x
# https://github.com/alpinelinux/alpine-conf/blob/master/setup-alpine.in

export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

HOSTNAME="${HOSTNAME:-alpine}"
PASSWORD="${PASSWORD:-alpine}"
VERSION="${VERSION:-3.9}"
KEYMAPOPTS="fr fr"
HOSTNAMEOPTS="-n ${HOSTNAME}"
INTERFACESOPTS="auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet dhcp
"
DNSOPTS="-n 8.8.8.8"
TIMEZONEOPTS="-z Europe/Paris"
PROXYOPTS="none"
APKREPOSOPTS="http://dl-cdn.alpinelinux.org/alpine/v${VERSION}/main"
SSHDOPTS="-c none"
NTPOPTS="-c openntpd"
DISKOPTS="-s 0 -m sys /dev/vda"

/sbin/setup-keymap ${KEYMAPOPTS}
/sbin/setup-hostname ${HOSTNAMEOPTS}
echo "${INTERFACESOPTS}" | /sbin/setup-interfaces -i
# /etc/init.d/networking --quiet start >/dev/null
# /sbin/setup-dns ${DNSOPTS}
/sbin/setup-timezone ${TIMEZONEOPTS}
/sbin/setup-proxy -q ${PROXYOPTS}
/sbin/setup-apkrepos ${APKREPOSOPTS}
/sbin/setup-ntp ${NTPOPTS}
/sbin/setup-sshd ${SSHDOPTS}
rc-update --quiet add networking boot
rc-update --quiet add urandom boot
/etc/init.d/hostname --quiet restart
openrc boot
openrc default

passwd <<EOF
$PASSWORD
$PASSWORD
EOF

echo "y" | DEFAULT_DISK="none" /sbin/setup-disk -q ${DISKOPTS} || exit
