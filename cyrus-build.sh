#!/bin/bash

c=${1:-$(buildah from base)}

buildah run $c sh -c 'zypper in -ly -t pattern devel_C_C++'
buildah run $c sh -c '\
zypper in -ly \
cyrus-sasl-devel \
gzip \
libical-devel \
libicu-devel \
libjansson-devel \
libopenssl-devel \
openldap2-devel && zypper clean -a'
curl -o - -L https://github.com/cyrusimap/cyrus-imapd/releases/download/cyrus-imapd-3.2.11/cyrus-imapd-3.2.11.tar.gz |
buildah run $c tar -zxf - -C /usr/src
buildah run $c sh -c 'cd /usr/src/cyrus-imapd-3.2.11 && \
./configure \
--prefix=/usr \
--bindir=/usr/cyrus/bin \
--libexecdir=/usr/cyrus/libexec \
--enable-autocreate \
--enable-idled \
--with-ldap \
--without-snmp && \
make && test 0 -eq $? && \
mkdir -p /target && \
DESTDIR=/target make install && \
for dir in perl/annotator perl/imap perl/sieve/managesieve;
do ( cd $dir ; make DESTDIR=/target install ); done && \
install tools/mkimap /target/usr/sbin/'

buildah commit $c $(basename -s .sh $0)
