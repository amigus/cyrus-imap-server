#!/bin/bash

c=${1:-$(buildah from base-build)}

buildah run $c zypper in -ly \
cyrus-sasl-devel \
libchardet-devel \
libicu-devel \
libjansson-devel \
libopenssl-devel \
libuchardet-devel \
perl-Authen-SASL-Cyrus \
openldap2-devel \
sqlite3-devel
buildah run $c zypper clean -a
curl -Lo - https://github.com/cyrusimap/cyrus-imapd/releases/download/cyrus-imapd-3.2.11/cyrus-imapd-3.2.11.tar.gz |
buildah run $c tar -zxf - -C /usr/src
buildah run $c install -d -m 755 -o root -g root /target
buildah run $c sh -c 'cd /usr/src/cyrus-imapd-3.2.11 && \
./configure \
--prefix=/usr \
--libexecdir=/usr/lib/cyrus-imapd \
--enable-autocreate \
--enable-idled \
--with-ldap \
--with-sqlite \
--without-snmp && \
DESTDIR=/target make install && \
for dir in perl/annotator perl/imap perl/sieve/managesieve;
do ( cd $dir ; make DESTDIR=/target install ); done && \
cd tools && install masssievec mkimap translatesieve /target/usr/bin/'

buildah commit $c $(basename -s .sh $0)
