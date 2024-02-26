# Cyrus IMAP + OpenLDAP + Postfix server

A [Cyrus IMAP](https://www.cyrusimap.org/)
server based on [OpenSUSE Leap](https://www.opensuse.org/#Leap)
that uses [OpenLDAP](https://www.openldap.org/)
for authentication and [Postfix](https://www.postfix.org/) for SMTP.

The scripts use [buildah](https://buildah.io/) to create the container images.
The containers are deployed via [podman](https://podman.io) using
[Kubernetes](https://kubernetes.io/)
[pod](https://kubernetes.io/docs/concepts/workloads/pods/) YAML.

The Cyrus IMAP server is built from sources.
The `./configure` invocation is in [cyrus-build.sh](blob/main/cyrus-build.sh).

```bash
./configure \
--prefix=/usr \
--bindir=/usr/cyrus/bin \
--libexecdir=/usr/cyrus/libexec \
--enable-autocreate \
--enable-idled \
--with-ldap \
--without-snmp
```

It _excludes_ GSSAPI (Kerberos) and JMAP, CalDAV, CardDAV, etc.

[cyrus.sh](cyrus.sh) copies the built output from  `cyrus-build`.
[base.sh](base.sh), [ldap.sh](ldap.sh) and
[postfix.sh](postfix.sh) have no dependencies.

The configuration is _not_ present, however,
the configuration files and directories are itemized in the YAML. 😉

## Create the images

```bash
sh base.sh
sh cyrus-build.sh
sh cyrus.sh
sh ldap.sh
sh postfix.sh
```

## Create the configuration

Me: 🤷

You: 🤔☝️🧑‍💻

## Run the pod

```bash
podman kube play pod.yaml
```

## Verify functioning

```sh
podman pod top email
```

Note the Cyrus IMAP and Postfix `master` processes and OpenLDAP `slapd`:

```shell
USER        PID         PPID        %CPU        ELAPSED           TTY         TIME        COMMAND
0           1           0           0.000       16m57.033261829s  ?           0s          /catatonit -P
root        1           0           0.000       16m57.034799388s  ?           0s          /usr/lib/postfix/bin//master -i
postfix     76          1           0.000       16m56.035001403s  ?           0s          pickup -l -t unix -u
postfix     77          1           0.000       16m56.035087065s  ?           0s          qmgr -l -t unix -u
postfix     80          1           0.000       15m2.035153747s   ?           0s          tlsmgr -l -t unix -u
ldap        1           0           0.000       16m57.038722838s  ?           0s          /usr/sbin/slapd -d 8 -h ldap:/// ldaps:/// -g ldap -u ldap
cyrus       1           0           0.000       16m57.040285888s  ?           0s          /usr/cyrus/libexec/master -D
cyrus       8           1           0.000       16m57.040405861s  ?           0s          imapd
cyrus       9           1           0.000       16m57.040455312s  ?           0s          imapd -s
cyrus       10          1           0.000       16m57.040500084s  ?           0s          idled
cyrus       11          1           0.000       16m57.040558185s  ?           0s          imapd
cyrus       12          1           0.000       16m57.040619397s  ?           0s          imapd -s
cyrus       14          1           0.000       2m48.040665748s   ?           0s          imapd -s
```