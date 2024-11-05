#!/bin/bash
set -x
# https://ubuntu.com/server/docs/install-and-configure-ldap
# https://docs.ezmeral.hpe.com/datafabric-customer-managed/78/Ranger/Configure_LDAP_AD_for_Ranger.html

ldapadd -x -D cn=admin,dc=docker,dc=net -H ldaps:/// -w hadoop <<EOF
dn: ou=users,dc=docker,dc=net
objectClass: organizationalUnit
ou: users

dn: ou=groups,dc=docker,dc=net
objectClass: organizationalUnit
ou: groups

dn: cn=posixgroup_a,ou=groups,dc=docker,dc=net
objectClass: posixGroup
cn: posixgroup_a
gidNumber: 5001

dn: uid=ldapuser,ou=users,dc=docker,dc=net
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
objectClass: person
uid: ldapuser
sn: u
givenName: L
cn: ldapuser
displayName: Ldap User
uidNumber: 10000
gidNumber: 5001
userPassword: {CRYPT}x
gecos: Ldap User
loginShell: /bin/bash
homeDirectory: /home/ldapuser

dn: uid=ldapuser1,ou=users,dc=docker,dc=net
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
objectClass: person
uid: ldapuser1
sn: u1
givenName: L
cn: ldapuser1
displayName: Ldap User1
uidNumber: 10001
gidNumber: 5001
userPassword: {CRYPT}x
gecos: Ldap User1
loginShell: /bin/bash
homeDirectory: /home/ldapuser1

dn: uid=ldapuser2,ou=users,dc=docker,dc=net
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
objectClass: person
uid: ldapuser2
sn: u2
givenName: L
cn: ldapuser2
displayName: Ldap User1
uidNumber: 10002
gidNumber: 5001
userPassword: {CRYPT}x
gecos: Ldap User2
loginShell: /bin/bash
homeDirectory: /home/ldapuser2

dn: uid=ldapuser3,ou=users,dc=docker,dc=net
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
objectClass: person
uid: ldapuser3
sn: u3
givenName: L
cn: ldapuser3
displayName: Ldap User3
uidNumber: 10003
gidNumber: 5001
userPassword: {CRYPT}x
gecos: Ldap User3
loginShell: /bin/bash
homeDirectory: /home/ldapuser3

dn: uid=ldapuser4,ou=users,dc=docker,dc=net
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
objectClass: person
uid: ldapuser4
sn: u4
givenName: L
cn: ldapuser4
displayName: Ldap User4
uidNumber: 10004
gidNumber: 5001
userPassword: {CRYPT}x
gecos: Ldap User4
loginShell: /bin/bash
homeDirectory: /home/ldapuser4

dn: cn=rangergroup_a,ou=groups,dc=docker,dc=net
objectClass: groupOfNames
member: uid=ldapuser1,ou=users,dc=docker,dc=net
member: uid=ldapuser2,ou=users,dc=docker,dc=net
cn: rangergroup_a

dn: cn=rangergroup_b,ou=groups,dc=docker,dc=net
objectClass: groupOfNames
member: uid=ldapuser3,ou=users,dc=docker,dc=net
member: uid=ldapuser4,ou=users,dc=docker,dc=net
cn: rangergroup_b

dn: cn=admin,ou=groups,dc=docker,dc=net
objectclass: groupOfNames
cn: admin
description: admin group for knox
member: uid=ldapuser,ou=users,dc=docker,dc=net
EOF

ldappasswd -D 'cn=admin,dc=docker,dc=net' -H ldaps:/// -w hadoop -x "uid=ldapuser,ou=users,dc=docker,dc=net" -s "pass"
for i in $(seq 4); do 
    ldappasswd -D 'cn=admin,dc=docker,dc=net' -H ldaps:/// -w hadoop -x "uid=ldapuser${i},ou=users,dc=docker,dc=net" -s "pass${i}"
done

# echo "start testing..."
# for i in $(seq 4); do ldapwhoami -x -D "uid=ldapuser${i},ou=users,dc=docker,dc=net" -H ldaps:/// -w "pass${i}"; done
# ldapsearch -x -D 'cn=admin,dc=docker,dc=net' -H ldaps:/// -w hadoop -b 'ou=users,dc=docker,dc=net' -LLL
# echo "stop testing."

# https://ubuntu.com/server/docs/how-to-set-up-kerberos-with-openldap-backend
# krbLoginFailedCount krbprincipalname krbprincipalkey krbLastPwdChange krbExtraData objectclass

slapd -h "ldapi://"

ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase={1}mdb,cn=config
add: olcAccess
olcAccess: {4}to dn.subtree="ou=users,dc=docker,dc=net"
  by dn.exact="uid=kdc-service,dc=docker,dc=net" read
  by dn.exact="uid=kadmin-service,dc=docker,dc=net" write
  by * break
EOF

pkill -f "slapd -h ldapi://"

sleep 3