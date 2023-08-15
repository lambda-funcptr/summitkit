#!/bin/bash

die() {
    exit 1;
}

cd $(dirname $0)/..

mkdir -p test/.pkgcache

podman run --privileged -v $(pwd)/src:/opt/bin:ro -v $(pwd)/test:/config:ro -v $(pwd)/test:/output -v $(pwd)/test/.pkgcache:/etc/apk/cache -it funcptr/summitkit || die

pushd test > /dev/null

if ! [ -e "esp.fat" ]; then
  touch esp.fat
  fallocate -z -l 256M esp.fat
  mformat -i esp.fat ::
fi

mcopy -no -s -i esp.fat EFI ::
mcopy -no -i esp.fat uki.efi ::/EFI/boot/bootx64.efi

popd > /dev/null
