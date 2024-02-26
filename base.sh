#!/bin/sh

c=${1:-$(buildah from opensuse/leap)}

buildah run $c sh -c 'zypper ref && zypper dup -ly'

buildah commit $c $(basename -s .sh $0)
