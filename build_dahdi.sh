#!/bin/bash -x

help() {
    echo "./convert.sh <coreos_channel> <coreos_version>"
    echo "Environment variables needed:"
    echo "Variable         Example"
    echo "DOCKER_REGISTRY  myprivaterepo.com"
    echo "COREOS_DEV_IMAGE coreos/dev-container"
    echo "KBUILDER_IMAGE   coreos/kmod-builder"
    echo "DAHDI_INJECTOR_IMAGE coreos/dahdi-injector"
    echo
    echo "Depending on your version of docker you might need to set DOCKER_API_VERSION."
    exit 1
}

COREOS_CHANNEL="$1"
COREOS_VERSION="$2"
DAHDI_VERSION="$3"

if [ -z "$COREOS_CHANNEL" ]; then
    echo "No CoreOS channel defined. Please set \$COREOS_CHANNEL"
    help
fi

if [ -z "$COREOS_VERSION" ]; then
    echo "No CoreOS version defined. Please set \$COREOS_VERSION"
    help
fi

if [ -z "$DAHDI_VERSION" ]; then
    echo "No Dahdi version defined. Please set \$DAHDI_VERSION"
    help
fi

if [ -z "$DOCKER_REGISTRY" ]; then
    echo "No private registry set. Please set \$DOCKER_REGISTRY"
    help
fi

cd kbuilder
./build.sh $COREOS_CHANNEL $COREOS_VERSION 

cd ../dahdi
./build.sh $COREOS_VERSION $DAHDI_VERSION
