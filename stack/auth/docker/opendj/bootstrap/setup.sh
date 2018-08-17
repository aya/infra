#!/usr/bin/env bash
# Default setup script


NUM_SAMPLE_USERS="${NUM_SAMPLE_USERS:-2000}"
echo "Setting up default OpenDJ instance"

# If any optional LDIF files are present load them

/opt/opendj/setup --cli -p 389 --ldapsPort 636 --enableStartTLS --generateSelfSignedCertificate \
  --baseDN $BASE_DN -h localhost --rootUserPassword "$PASSWORD" \
  --acceptLicense --no-prompt --sampleData "${NUM_SAMPLE_USERS}"


#LDIF=""
if [ -d /opt/opendj/bootstrap/ldif ]; then
   echo "Found optional schema files in bootstrap/ldif. Will load them"
  for file in /opt/opendj/bootstrap/ldif/*;  do
      echo "Loading $file"
      /opt/opendj/bin/ldapmodify -D "cn=Directory Manager" -h localhost -p 389 -w $PASSWORD -f $file
  done
fi


