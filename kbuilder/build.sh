#!/bin/bash

help() {
    echo "./convert.sh <coreos_channel> <coreos_version>"
    echo "Environment variables needed:"
    echo "Variable         Example"
    echo "DOCKER_REGISTRY  myprivaterepo.com"
    echo "COREOS_DEV_IMAGE coreos/dev-container"
    echo "KBUILDER_IMAGE   coreos/kmod-builder"
    echo
    echo "Depending on your version of docker you might need to set DOCKER_API_VERSION."
    exit 1
}

if [ "$#" -ne 2 ]; then
    help
fi

COREOS_CHANNEL="$1"
COREOS_VERSION="$2"

if [ -z "$COREOS_CHANNEL" ]; then
    echo "No CoreOS channel defined. Please set \$COREOS_CHANNEL"
    help
fi

if [ -z "$COREOS_VERSION" ]; then
    echo "No CoreOS version defined. Please set \$COREOS_VERSION"
    help
fi

if [ -z "$DOCKER_REGISTRY" ]; then
    echo "No private registry set. Please set \$DOCKER_REGISTRY"
    help
fi

if [ -z "$COREOS_DEV_IMAGE" ]; then
    echo "No image name for CoreOS dev container. Please set \$COREOS_DEV_IMAGE"
    echo "Defaulting to: coreos/dev-container"
    COREOS_DEV_IMAGE="coreos/dev-container"
fi

if [ -z "$KBUILDER_IMAGE" ]; then
    echo "No image name for CoreOS kernel modules builder. Please set \$KBUILDER_IMAGE"
    echo "Defaulting to: coreos/kmod-builder"
    KBUILDER_IMAGE="coreos/kmod-builder"
fi

COREOS_DEV_TAG="$COREOS_VERSION"
COREOS_DEV_TARGET="$DOCKER_REGISTRY/$COREOS_DEV_IMAGE:$COREOS_DEV_TAG"

KBUILDER_TAG="$COREOS_VERSION"
KBUILDER_TARGET="$DOCKER_REGISTRY/$KBUILDER_IMAGE:$KBUILDER_TAG"

COREOS_MAJOR_VERSION=$(echo "$COREOS_VERSION"|cut -d"." -f1)

# Check if we've built it already
if curl -q "https://$DOCKER_REGISTRY/v2/$KBUILDER_IMAGE/tags/list" |grep -q "$KBUILDER_TAG"; then
    echo "Kernel builder image $KBUILDER_TARGET already present, skipping!"
    exit 0
fi

mkdir ../images 2>/dev/null
mkdir dockerfiles 2>/dev/null

DOCKER_OPTS="-e=COREOS_CHANNEL=$COREOS_CHANNEL -e=COREOS_VERSION=$COREOS_VERSION -e=COREOS_DEV_TARGET=${COREOS_DEV_TARGET} -v=/var/run/docker.sock:/var/run/docker.sock -v=$(pwd)/../images:/images"
if [ ! -z "$DOCKER_API_VERSION" ]; then
    DOCKER_OPTS="$DOCKER_OPTS -e=DOCKER_API_VERSION=$DOCKER_API_VERSION"
fi

docker run $DOCKER_OPTS mathpl/coreos-container-extractor:0.1
if [ "$?" != 0 ]; then
    exit $?
fi

sed -re "s|<DOCKER_FROM>|$COREOS_DEV_TARGET|" -e "s|<COREOS_MAJOR_VERSION>|$COREOS_MAJOR_VERSION|" Dockerfile.template > dockerfiles/Dockerfile.$COREOS_VERSION

docker build -f dockerfiles/Dockerfile.$COREOS_VERSION -t $KBUILDER_TARGET .
