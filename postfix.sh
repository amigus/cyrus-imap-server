#!/bin/bash

c=${1:-$(buildah from base)}

buildah run $c sh -c '\
zypper in -ly \
cyrus-sasl-ldap-auxprop \
cyrus-sasl-plain \
cyrus-sasl-scram \
postfix postfix-ldap && zypper clean -a'
buildah run $c groupadd -g 478 tls
buildah run $c usermod -a -G tls postfix
buildah run $c postmap /etc/postfix/relay /etc/postfix/relay_recipients

buildah config --cmd '["/usr/sbin/postfix", "start-fg"]' $c

buildah commit $c $(basename -s .sh $0)
