#!/bin/bash

c=${1:-$(buildah from base-build)}
version=${2:-"3.2.12"}

dist="https://github.com/cyrusimap/cyrus-imapd/releases/download/cyrus-imapd-$version/cyrus-imapd-$version.tar.gz"

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
curl -sLo - $dist |
buildah run --workingdir /usr/src $c tar -zxf -
buildah run $c install -d -m 755 -o root -g root /target
buildah run --workingdir /usr/src/cyrus-imapd-$version $c sh <<EOF
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
do ( cd \$dir ; make DESTDIR=/target install ); done && \
cd tools && install masssievec mkimap translatesieve /target/usr/bin/
EOF

buildah commit $c $(basename -s .sh $0)