#!/bin/bash

#https://ubuntu.com/server/docs/how-to-set-up-kerberos-with-openldap-backend

apt-get update && apt install krb5-kdc-ldap krb5-admin-server nano ca-certificates -y 
    # Default Kerberos version 5 realm: DOCKER.NET
    # Kerberos servers for your realm: kdc-server.docker.net
    # Administrative server for your Kerberos realm: kdc-server.docker.net

nano /etc/krb5.conf
# [realms]
# 	docker.net = {
# 		kdc = kdc-server.docker.net
# 		admin_server = kdc-server.docker.net
# 		default_domain = docker.net
#       database_module = openldap_ldapconf
# 	}

# [dbdefaults]
#         ldap_kerberos_container_dn = cn=krbContainer,dc=docker,dc=net

# [dbmodules]
#         openldap_ldapconf = {
#                 db_library = kldap

# 				# if either of these is false, then the ldap_kdc_dn needs to
# 				# have write access
# 				disable_last_success = true
# 				disable_lockout  = true

#                 # this object needs to have read rights on
#                 # the realm container, principal container and realm sub-trees
#                 ldap_kdc_dn = "uid=kdc-service,dc=docker,dc=net"

#                 # this object needs to have read and write rights on
#                 # the realm container, principal container and realm sub-trees
#                 ldap_kadmind_dn = "uid=kadmin-service,dc=docker,dc=net"

#                 ldap_service_password_file = /etc/krb5kdc/keyfiles/service.keyfile
#                 ldap_servers = ldaps://ldap-server.docker.net
#                 ldap_conns_per_server = 5
#           }

echo "*/admin@EXAMPLE.COM    *" >> /etc/krb5kdc/kadm5.acl
apt remove nano -y 