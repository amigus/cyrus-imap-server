#!/bin/bash

c=${1:-$(buildah from base)}

buildah run $c sh -c '\
zypper in -ly \
cyrus-sasl-ldap-auxprop \
cyrus-sasl-plain \
cyrus-sasl-scram \
libicu-suse65_1 \
libjansson4 \
openssl tar && zypper clean -a'

echo 'lmtp 2003/tcp # Lightweight Mail Transport Protocol service' |
buildah run $c sh -c 'cat >> /etc/services'
buildah run $(buildah from cyrus-build) tar -C /target -cf - . |
buildah run $c tar xpf - -C /
buildah run $c /sbin/ldconfig
buildah run $c groupadd -g 12 mail
buildah run $c groupadd -g 478 tls
buildah run $c useradd -u 76 -g 12 -G tls -d /var/lib/cyrus -M cyrus

buildah config --cmd '["/usr/cyrus/libexec/master", "-D"]' $c

buildah commit $c $(basename -s .sh $0)
