#/bin/bash

cd $(dirname $0)

# need: multiarch/qemu-user-static
buildah manifest exists localhost/funcptr/summitkit && buildah manifest rm localhost/funcptr/summitkit
buildah manifest create localhost/funcptr/summitkit
buildah build -f summit.docker --platform="linux/amd64" --manifest localhost/funcptr/summitkit --label latest
