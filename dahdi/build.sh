#!/bin/bash -x

help() {
    echo "./convert.sh <coreos_version> <spl_version> <zfs_version>"
    echo "Environment variables needed:"
    echo "Variable         Example"
    echo "DOCKER_REGISTRY  myprivaterepo.com"
    echo "KBUILDER_IMAGE   coreos/kmod-builder"
    echo
    echo "Depending on your version of docker you might need to set DOCKER_API_VERSION."
    exit 1
}

if [ "$#" -ne 2 ]; then
    help
fi

COREOS_VERSION="$1"
DAHDI_VERSION="$2"

if [ -z "$COREOS_VERSION" ]; then
    echo "No CoreOS version defined. Please set \$COREOS_VERSION"
    help
fi

if [ -z "$DAHDI_VERSION" ]; then
    echo "No Dahdi version defined. Please set \$DAHDI_VERSION"
    help
fi

if [ -z "$KBUILDER_IMAGE" ]; then
    echo "No image name for CoreOS kernel modules builder. Please set \$KBUILDER_IMAGE"
    echo "Defaulting to: coreos/kmod-builder"
    KBUILDER_IMAGE="coreos/kmod-builder"
fi

if [ -z "$DAHDI_BUILDER_IMAGE" ]; then
    echo "No image name for Dahdi kernel modules builder. Please set \$DAHDI_BUILDER_IMAGE"
    echo "Defaulting to: coreos/dahdi-builder"
    DAHDI_BUILDER_IMAGE="coreos/dahdi-builder"
fi

if [ -z "$DAHDI_INJECTOR_IMAGE" ]; then
    echo "No image name for Dahdi kernel modules builder. Please set \$DAHDI_INJECTOR_IMAGE"
    echo "Defaulting to: coreos/dahdi-builder"
    DAHDI_INJECTOR_IMAGE="coreos/dahdi-injector"
fi

KBUILDER_TAG="$COREOS_VERSION"
KBUILDER_TARGET="$DOCKER_REGISTRY/$KBUILDER_IMAGE:$KBUILDER_TAG"

DAHDI_TAG="$COREOS_VERSION-$DAHDI_VERSION"
DAHDI_BUILDER_TARGET="$DOCKER_REGISTRY/$DAHDI_BUILDER_IMAGE:$COREOS_VERSION"
DAHDI_INJECTOR_TARGET="$DOCKER_REGISTRY/$DAHDI_INJECTOR_IMAGE:$DAHDI_TAG"

# Check if we've built it already
#if curl -q "https://$DOCKER_REGISTRY/v2/$DAHDI_INJECTOR_IMAGE/tags/list" |grep -q "$DAHDI_TAG"; then
#    echo "Kernel builder image $KBUILDER_TARGET already present, skipping!"
#    exit 0
#fi

mkdir dockerfiles 2>/dev/null || true
sed -re "s|<DOCKER_FROM>|$KBUILDER_TARGET|" Dockerfile.builder.template > dockerfiles/Dockerfile.builder.$COREOS_VERSION
docker build -f dockerfiles/Dockerfile.builder.$COREOS_VERSION -t $DAHDI_BUILDER_TARGET .
if [ $? -ne 0 ]; then
  echo "Failed to build builers: $?"
  exit 1
fi

MOD_DIR="modules/$COREOS_VERSION-$DAHDI_VERSION"
mkdir $MOD_DIR 2>/dev/null
DOCKER_OPTS="-e=COREOS_VERSION=$COREOS_VERSION -e=DAHDI_VERSION=${DAHDI_VERSION} -v=$(pwd)/$MOD_DIR:/mod_dir -v=$(pwd)/dahdi-linux:/pkg"

docker run $DOCKER_OPTS $DAHDI_BUILDER_TARGET build
if [ $? -ne 0 ]; then
  echo "Failed to build modules: $?"
  exit 1
fi

sed -re "s|<VERSION>|$DAHDI_TAG|" Dockerfile.injector.template > dockerfiles/Dockerfile.injector.$DAHDI_TAG
docker build -f dockerfiles/Dockerfile.injector.$DAHDI_TAG -t $DAHDI_INJECTOR_TARGET .
if [ $? -ne 0 ]; then
  echo "Failed to build injector: $?"
  exit 1
fi
docker push $DAHDI_INJECTOR_TARGET
