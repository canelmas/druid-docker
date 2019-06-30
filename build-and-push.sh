#!/bin/bash

build_and_push() {
    docker build -t canelmas/druid:$1 .
    docker push canelmas/druid:$1
}

if [ $# -lt 1 ]; then
    echo "Usage: build-and-push <tag>"
    exit 1
else
    build_and_push $1
fi