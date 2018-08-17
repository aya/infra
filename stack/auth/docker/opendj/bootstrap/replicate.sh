#!/usr/bin/env bash
# Replicate to the master server hostname defined in $1
# If that server is ourself this is a no-op

MASTER=$1


# This is a bit  kludgy.
# The hostname has to be a fully resolvable DNS name in the cluster
# If the service is called

MYHOSTNAME=`hostname -f`

echo "Setting up replication from $MYHOSTNAME to $MASTER"


# For debug


# K8s puts the service name in /etc/hosts
if grep ${MASTER} /etc/hosts; then
 echo "We are the master. Skipping replication setup to ourselves"
 exit 0
fi

# Comment out
echo "replicate ENV vars:"
env



echo "enabling replication"

# todo: Replace with command to test for master being reachable and up
# This is hacky....
echo "Will sleep for a bit to ensure master is up"

sleep 30


bin/dsreplication enable --host1 $MYHOSTNAME --port1 4444 \
  --bindDN1 "cn=directory manager" \
  --bindPassword1 $PASSWORD --replicationPort1 8989 \
  --host2 $MASTER --port2 4444 --bindDN2 "cn=directory manager" \
  --bindPassword2 $PASSWORD --replicationPort2 8989 \
  --adminUID admin --adminPassword $PASSWORD --baseDN $BASE_DN -X -n

echo "initializing replication"

bin/dsreplication initialize --baseDN $BASE_DN \
  --adminUID admin --adminPassword $PASSWORD \
  --hostSource $MASTER --portSource 4444 \
  --hostDestination $MYHOSTNAME --portDestination 4444 -X -n

