#!/bin/bash

c=${1:-$(buildah from base)}

buildah run $c zypper in -ly \
cyrus-sasl-ldap-auxprop \
cyrus-sasl-plain \
cyrus-sasl-scram \
postfix \
postfix-ldap
buildah run $c zypper clean -a
buildah run $c groupadd -g 478 tls
buildah run $c usermod -a -G tls postfix

buildah config --cmd '["/usr/sbin/postfix", "start-fg"]' $c

buildah commit $c $(basename -s .sh $0)
