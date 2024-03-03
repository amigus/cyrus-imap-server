#!/bin/bash

c=${1:-$(buildah from base)}

buildah run $c zypper in -ly \
cyrus-sasl-ldap-auxprop \
cyrus-sasl-scram \
openldap2
buildah run $c zypper clean -a 
echo 'auxprop_plugin: slapd' |
buildah run $c sh -c 'cat >| /etc/sasl2/slapd.conf'
buildah run $c install -d -m 0755 -g ldap -o ldap /run/slapd
buildah run $c groupadd -g 478 tls
buildah run $c usermod -a -G tls ldap

buildah config --cmd '["/usr/sbin/slapd", "-d", "0", "-h", "ldapi://%2Frun%2Fslapd%2Fsocket%2Fldapi", "-g", "ldap", "-u", "ldap"]' $c

buildah commit $c $(basename -s .sh $0)
