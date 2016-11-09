#!/bin/bash

DOCKER_REGISTRY="$1"
COREOS_CHANNEL="$2"
COREOS_VERSION="$3"

DOCKER_IMAGE="coreos/dev-container-builder"
DOCKER_TAG="$COREOS_VERSION"
DOCKER_TARGET="$DOCKER_REGISTRY/$DOCKER_IMAGE:$DOCKER_TAG"

KBUILDER_IMAGE="coreos/kmod-builder"
KBUILDER_TAG="$COREOS_VERSION"
KBUILDER_TARGET="$DOCKER_REGISTRY/$KBUILDER_IMAGE:$KBUILDER_TAG"

if [ -z "$COREOS_CHANNEL" ]; then
    echo "No CoreOS channel defined. Please set \$COREOS_CHANNEL"
    exit 1
fi

if [ -z "$COREOS_VERSION" ]; then
    echo "No CoreOS version defined. Please set \$COREOS_VERSION"
    exit 1
fi

COREOS_MAJOR_VERSION=$(echo "$COREOS_VERSION"|cut -d"." -f1)

# Check if we've built it already
if curl -q "https://$DOCKER_REGISTRY/v2/$KBUILDER_IMAGE/tags/list" |grep -q "$KBUILDER_TAG"; then
    echo "Kernel builder image $KBUILDER_TARGET already present, skipping!"
    exit 0
fi

mkdir images 2>/dev/null

docker run -e=COREOS_CHANNEL=$COREOS_CHANNEL -e=COREOS_VERSION=$COREOS_VERSION -e=DOCKER_TARGET=${DOCKER_TARGET} -v=/var/run/docker.sock:/tmp/docker.sock -v=$(pwd)/images:/images mathpl/coreos-container-extractor:0.1
if [ "$?" != 0 ]; then
    exit $?
fi

mkdir tmp 2>/dev/null
sed -re "s|<DOCKER_FROM>|$DOCKER_TARGET|" -e "s|<COREOS_MAJOR_VERSION>|$COREOS_MAJOR_VERSION|" Dockerfile.template > tmp/Dockerfile.$COREOS_VERSION

docker build -f tmp/Dockerfiles.$COREOS_VERSION -t $KBUILDER_TARGET .
