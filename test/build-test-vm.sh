#!/bin/bash

cd $(dirname $0)/..

mkdir -p test/.pkgcache

podman run --privileged -v $(pwd)/src:/opt/bin:ro -v $(pwd)/test:/config:ro -v $(pwd)/test:/output -v $(pwd)/test/.pkgcache:/etc/apk/cache -it funcptr/summitkit
