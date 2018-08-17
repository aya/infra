#!/usr/bin/env bash
# Prepare CTS.  A variant of the script that is in the Admin guide
#
# copyright (C) 2014 ForgeRock AS
#
# cts-setup.sh: This script installs and configures an external CTS data store.
# It assumes that you have downloaded the OpenDJ zip file to a local
# folder.

echo "Configuring CTS"

cd /opt/opendj

# Reset the tmp folder
T=/tmp/ldif
rm -rf $T
mkdir $T

# Define variables used in this script. Make them specific to your deployment.

#LDIF_DIR=/usr/local/tomcat/webapps/openam/WEB-INF/template/ldif/sfha
LDIF_DIR=/opt/opendj/bootstrap/cts/sfha

PASS=${PASSWORD:-password}

# Comment this out when everything works...
echo "CTS password is $PASSWORD"


USER="cn=Directory Manager"
PORT=4444
CTS_DN="dc=cts,dc=forgerock,dc=com"

# Set CTS password the same as dir manager
CTS_ADMIN_PW="$PASS"


# Create a properties file for the OpenDJ install
cat > $T/setup.props <<EOF
# Sample properties file to set up the OpenDJ directory server
hostname                      = localhost
ldapPort                      = 389
generateSelfSignedCertificate = true
enableStartTLS                = true
ldapsPort                     = 636
jmxPort                       = 1689
adminConnectorPort            = $PORT
rootUserDN                    = $USER
rootUserPassword              = $PASS
baseDN                        = $CTS_DN
##ldifFile                    = /path/to/Example.ldif
##sampleData                  =

EOF


# Create the CTS base dn and ACIs entries and write them to a file
# Linefeeds have been added for publication purposes.
cat > $T/add-cts-entries.ldif <<EOF
dn: $CTS_DN
objectclass: top
objectclass: domain
dc: cts
aci: (targetattr="*")(version 3.0;acl "Allow entry search";
 allow (search, read)(userdn = "ldap:///uid=openam,ou=admins,$CTS_DN");)
aci: (targetattr="*")(version 3.0;acl "Modify config entry";
 allow (write)(userdn = "ldap:///uid=openam,ou=admins,$CTS_DN");)
aci: (targetcontrol="2.16.840.1.113730.3.4.3")
 (version 3.0;acl "Allow persistent search";
 allow (search, read)(userdn = "ldap:///uid=openam,ou=admins,$CTS_DN");)
aci: (version 3.0;acl "Add config entry"; allow (add)(userdn = "ldap:///uid=openam,ou=admins,$CTS_DN");)
aci: (version 3.0;acl "Delete config entry"; allow (delete)(userdn = "ldap:///uid=openam,ou=admins,$CTS_DN");)

dn: ou=admins,$CTS_DN
objectclass: top
objectclass: organizationalUnit
ou: admins

dn: uid=openam,ou=admins,$CTS_DN
objectclass: top
objectclass: person
objectclass: organizationalPerson
objectclass: inetOrgPerson
cn: openam
sn: openam
uid: openam
userPassword: $CTS_ADMIN_PW
ds-privilege-name: subentry-write
ds-privilege-name: update-schema
EOF

#./setup --cli --propertiesFilePath $T/setup.props --acceptLicense --no-prompt --doNotStart
./setup --cli --propertiesFilePath $T/setup.props --acceptLicense --no-prompt


#cd opendj

# Create the CTS Backend
# We should not need to do this unless we want to change the backend type
#echo ""
#echo "... Creating backend ..."
#echo ""
#bin/dsconfig create-backend \
#--backend-name cts-store \
#--set base-dn:"$CTS_DN" \
#--set enabled:true \
#--type local-db \
#--port $PORT \
#--bindDN "$USER" \
#--bindPassword $PASS \
#--trustAll \
#--no-prompt
#echo "Backend created"

# Verify Backend
bin/dsconfig list-backends \
--port $PORT \
--bindDN "$USER" \
--bindPassword $PASS \
--trustAll --no-prompt

# Add the Base DN and ACIs
echo ""
echo "...Adding Base DN and ACIs..."
echo ""
bin/ldapmodify \
--port $PORT \
--bindDN "$USER" \
--bindPassword $PASS \
--defaultAdd \
--filename $T/add-cts-entries.ldif \
--useSSL \
--trustAll
echo "BaseDN and ACIs added."

# Verify BaseDN and ACIs
bin/ldapsearch --port $PORT --bindDN "$USER" --bindPassword $PASS \
 --baseDN "$CTS_DN" --searchscope sub --useSSL --trustAll  "(objectclass=*)"



# Add the Admin Global ACI
echo ""
echo "...Adding Admin Global ACIs..."
echo ""
bin/dsconfig set-access-control-handler-prop \
--add global-aci:'(target = "ldap:///cn=schema")(targetattr = "attributeTypes || objectClasses")(version 3.0; acl "Modify schema"; allow (write) userdn = "ldap:///uid=openam,ou=admins,'${CTS_DN}'";)' \
--port $PORT \
--bindDN "$USER" \
--bindPassword $PASS \
--trustAll \
--no-prompt
echo "Global ACI added."


# Verify Global ACI
bin/dsconfig get-access-control-handler-prop --property global-aci --port $PORT \
 --bindDN "$USER" --bindPassword $PASS -X -n

# Copy the Schema, Indexes, and Container files for CTS
echo ""
echo "... Begin copying schema, indexes, and container ..."
cp $LDIF_DIR/cts-add-schema.ldif $T/cts-add-schema.ldif
cat $LDIF_DIR/cts-indices.ldif | sed -e 's/@DB_NAME@/cts-store/' > $T/cts-indices.ldif
cat $LDIF_DIR/cts-container.ldif | sed -e \
 "s/@SM_CONFIG_ROOT_SUFFIX@/$CTS_DN/" > $T/cts-container.ldif
echo "Schema, index, and container files copied."

# Add the Schema Files
echo ""
echo "... Adding CTS Schema ..."
bin/ldapmodify --port $PORT --bindDN "$USER" --bindPassword $PASS \
 --fileName $T/cts-add-schema.ldif --useSSL --trustAll

# Add the CTS Indexes
# This can not be done via ldapmodify - must be dsconfig
# TODO: this is from the following script
# https://forgerock.org/openam/doc/bootstrap/resources/cts-add-indexes.txt
echo "... Adding CTS Indexes ..."
bin/dsconfig -p 4444 -D "cn=Directory Manager" -w $PASS -F bootstrap/cts/cts-add-indexes.txt -X -n

# Add the CTS Container Files
echo ""
echo "... Adding CTS Container ..."
bin/ldapmodify --port $PORT --bindDN "$USER" --bindPassword "$PASS" --defaultAdd \
 --fileName $T/cts-container.ldif --useSSL --trustAll

# Rebuild the Indexes
echo ""
echo "... Rebuilding Index ..."
bin/rebuild-index --port $PORT --bindDN "$USER" --bindPassword "$PASS" \
 --baseDN "$CTS_DN" --rebuildALL --start 0 --trustAll

# Verify the Indexes
#echo ""
#echo "... Verifying Index ..."
#bin/verify-index --baseDN "$CTS_DN"

echo ""
echo "Your CTS External Store has been configured."

echo "Setting custom java properties"
cp bootstrap/cts/java.properties /opt/opendj/data/config
bin/dsjavaproperties

