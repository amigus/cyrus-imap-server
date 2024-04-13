all: cyrus ldap postfix
base-build ldap postfix: base
cyrus-build: base-build
cyrus: cyrus-build
%: %.sh; sh $<
clean:
        buildah containers -aq | xargs buildah rm
        buildah images --filter after=registry.opensuse.org/opensuse/leap:latest -q |\
        xargs buildah rmi -f