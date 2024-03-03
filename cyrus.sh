#!/bin/bash

c=${1:-$(buildah from base)}

buildah run $c zypper in -ly \
cyrus-sasl-ldap-auxprop \
cyrus-sasl-gssapi \
cyrus-sasl-plain \
cyrus-sasl-scram \
libicu-suse65_1 \
libchardet1 \
libuchardet0 \
libjansson4 \
openssl \
sqlite3 \
tar \
uchardet
buildah run $c zypper clean -a
buildah run $(buildah from cyrus-build) tar -C /target -cf - . |
buildah run $c tar xpf - -C /
buildah run $c /sbin/ldconfig
buildah run $c groupadd -g 12 mail
buildah run $c groupadd -g 478 tls
buildah run $c useradd -u 76 -g 12 -G tls -d /var/lib/cyrus -M cyrus

buildah config --cmd '["/usr/lib/cyrus-imapd/master", "-D"]' $c

buildah commit $c $(basename -s .sh $0)
