#https://ubuntu.com/server/docs/how-to-set-up-kerberos-with-openldap-backend

apt install krb5-kdc-ldap krb5-admin-server schema2ldif nano -y
    #Default Kerberos version 5 realm: DOCKER.NET
    #Kerberos servers for your realm: kdc-server.docker.net
    #Administrative server for your Kerberos realm: kdc-server.docker.net
nano /etc/ldap/schema/kerberos.schema #добавляем код
ldap-schema-manager -i kerberos.schema
#ldapsearch -QLLLY EXTERNAL -H ldapi:/// -b cn=schema,cn=config dn | grep -i kerberos
#ldapsearch -QLLLY EXTERNAL -H ldapi:/// -b cn={4}kerberos,cn=schema,cn=config | grep NAME | cut -d' ' -f5 | sort
ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase={1}mdb,cn=config
add: olcDbIndex
olcDbIndex: krbPrincipalName eq,pres,sub
EOF
ldapadd -x -D cn=admin,dc=docker,dc=net -W <<EOF
dn: uid=kdc-service,dc=docker,dc=net
uid: kdc-service
objectClass: account
objectClass: simpleSecurityObject
userPassword: {CRYPT}x
description: Account used for the Kerberos KDC

dn: uid=kadmin-service,dc=docker,dc=net
uid: kadmin-service
objectClass: account
objectClass: simpleSecurityObject
userPassword: {CRYPT}x
description: Account used for the Kerberos Admin server
EOF
    #Enter LDAP Password: hadoop
ldappasswd -x -D cn=admin,dc=docker,dc=net -W -S uid=kdc-service,dc=docker,dc=net 
    #New password: hadoop; 
    #Enter LDAP Password: hadoop
#ldapwhoami -x -D uid=kdc-service,dc=docker,dc=net -W
    #Enter LDAP Password: hadoop
ldappasswd -x -D cn=admin,dc=docker,dc=net -W -S uid=kadmin-service,dc=docker,dc=net
    #New password: hadoop; 
    #Enter LDAP Password: hadoop
#ldapwhoami -x -D uid=kadmin-service,dc=docker,dc=net -W
    #Enter LDAP Password: hadoop
ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase={1}mdb,cn=config
add: olcAccess
olcAccess: {2}to attrs=krbPrincipalKey
  by anonymous auth
  by dn.exact="uid=kdc-service,dc=docker,dc=net" read
  by dn.exact="uid=kadmin-service,dc=docker,dc=net" write
  by self write
  by * none
-
add: olcAccess
olcAccess: {3}to dn.subtree="cn=krbContainer,dc=docker,dc=net"
  by dn.exact="uid=kdc-service,dc=docker,dc=net" read
  by dn.exact="uid=kadmin-service,dc=docker,dc=net" write
  by * none
EOF
#slapcat -b cn=config
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

#                 ldap_service_password_file = /etc/krb5kdc/service.keyfile
#                 ldap_servers = ldapi:///
#                 ldap_conns_per_server = 5
#           }


kdb5_ldap_util -D cn=admin,dc=docker,dc=net create -subtrees dc=docker,dc=net -r DOCKER.NET -s -H ldapi:/// 
    #Password for "cn=admin,dc=docker,dc=net": hadoop
    #Enter KDC database master key: hadoop
kdb5_ldap_util -D cn=admin,dc=docker,dc=net stashsrvpw -f /etc/krb5kdc/service.keyfile uid=kdc-service,dc=docker,dc=net
    #Password for "cn=admin,dc=docker,dc=net": hadoop
    #Password for "uid=kdc-service,dc=docker,dc=net": hadoop
kdb5_ldap_util -D cn=admin,dc=docker,dc=net stashsrvpw -f /etc/krb5kdc/service.keyfile uid=kadmin-service,dc=docker,dc=net
    #Password for "cn=admin,dc=docker,dc=net": hadoop
    #Password for "uid=kdc-service,dc=docker,dc=net": hadoop
echo "*/admin@EXAMPLE.COM    *" >> /etc/krb5kdc/kadm5.acl
#krb5kdc
#kadmind

#kadmin.local -> addprinc
#The above will create an ubuntu principal with a DN of krbPrincipalName=ubuntu@EXAMPLE.COM,cn=EXAMPLE.COM,cn=krbContainer,dc=example,dc=com



- `apt-get update`
- `apt install krb5-kdc krb5-admin-server -y` (Default Kerberos version 5 realm: DOCKER.NET, Kerberos servers for your realm: kdc-server.docker.net, Administrative server for your Kerberos realm: kdc-server.docker.net)
- `krb5_newrealm` (Enter KDC database master key: hadoop)
- `echo "hdfs@DOCKER.NET *" >> /etc/krb5kdc/kadm5.acl`
- `echo "yarn@DOCKER.NET *" >> /etc/krb5kdc/kadm5.acl`
- `echo "mapred@DOCKER.NET *" >> /etc/krb5kdc/kadm5.acl`

