#!/bin/sh

c=${1:-$(buildah from opensuse/leap)}

buildah run $c zypper dup -ly
buildah run $c sh -c 'cat >>/etc/services'<<EOF
pop3               110/tcp      # Post Office Protocol v3
nntp               119/tcp      # Network News Transport Protocol
imap               143/tcp      # Internet Mail Access Protocol rev4
imaps              993/tcp      # IMAP over TLS
pop3s              995/tcp      # POP3 over TLS
kpop               1109/tcp     # Kerberized Post Office Protocol
lmtp               2003/tcp     # Lightweight Mail Transport Protocol service
smmap              2004/tcp     # Cyrus smmapd (quota check) service
csync              2005/tcp     # Cyrus replication service
nntps              563/tcp      # NNTP over TLS
mupdate            3905/tcp     # Cyrus mupdate service
sieve              4190/tcp     # timsieved Sieve Mail Filtering Language service
EOF

buildah commit $c $(basename -s .sh $0)
