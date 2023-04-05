#!/bin/bash

cd $(dirname $0)/..

podman run --privileged -v $(pwd)/src:/opt/bin:ro -v $(pwd)/test:/config:ro -v $(pwd)/test:/output -it funcptr/summitkit
