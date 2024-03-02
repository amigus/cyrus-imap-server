#!/bin/sh

c=${1:-$(buildah from base)}

buildah run $c zypper in -ly -t pattern devel_C_C++
buildah run $c zypper in -ly file gzip krb5-devel

buildah commit $c $(basename -s .sh $0)
