#https://ubuntu.com/server/docs/ldap-and-transport-layer-security-tls

apt update
apt install slapd ldap-utils gnutls-bin ssl-cert ca-certificates -y 
    #Administrator password: hadoop
certtool --generate-privkey --bits 4096 --outfile /etc/ssl/private/mycakey.pem
echo "cn = Example Company
ca
cert_signing_key
expiration_days = 3650" >> /etc/ssl/ca.info
certtool --generate-self-signed --load-privkey /etc/ssl/private/mycakey.pem --template /etc/ssl/ca.info --outfile /usr/local/share/ca-certificates/mycacert.crt
update-ca-certificates
certtool --generate-privkey --bits 2048 --outfile /etc/ldap/ldap01_slapd_key.pem
echo "organization = Example Company
cn = kdc-server.docker.net
tls_www_server
encryption_key
signing_key
expiration_days = 365" >> /etc/ssl/ldap01.info
certtool --generate-certificate --load-privkey /etc/ldap/ldap01_slapd_key.pem --load-ca-certificate /etc/ssl/certs/mycacert.pem --load-ca-privkey /etc/ssl/private/mycakey.pem --template /etc/ssl/ldap01.info --outfile /etc/ldap/ldap01_slapd_cert.pem
echo "dn: cn=config
add: olcTLSCACertificateFile
olcTLSCACertificateFile: /etc/ssl/certs/mycacert.pem
-
add: olcTLSCertificateFile
olcTLSCertificateFile: /etc/ldap/ldap01_slapd_cert.pem
-
add: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/ldap/ldap01_slapd_key.pem" >> certinfo.ldif
slapd -h "ldap:// ldapi://"
ldapmodify -Y EXTERNAL -H ldapi:/// -f certinfo.ldif
pkill -f slapd
slapd -h "ldap:// ldapi:// ldaps://"
#ldapwhoami -x -ZZ -H ldap://kdc-server.docker.net
#ldapwhoami -x -H ldaps://kdc-server.docker.net