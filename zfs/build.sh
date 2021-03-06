#!/bin/bash

help() {
    echo "./convert.sh <coreos_version> <spl_version> <zfs_version>"
    echo "Environment variables needed:"
    echo "Variable         Example"
    echo "DOCKER_REGISTRY  myprivaterepo.com"
    echo "KBUILDER_IMAGE   coreos/kmod-builder"
    echo
    echo "Depending on your version of docker you might need to set DOCKER_API_VERSION."
    echo "Set BUILDER_NOPKG for version of CoreOS without pre-built package available from CoreOS."
    exit 1
}

if [ "$#" -ne 3 ]; then
    help
fi

COREOS_VERSION="$1"
SPL_VERSION="$2"
ZFS_VERSION="$3"

if [ -z "$COREOS_VERSION" ]; then
    echo "No CoreOS version defined. Please set \$COREOS_VERSION"
    help
fi

if [ -z "$SPL_VERSION" ]; then
    echo "No Solaris Porting Layer version defined. Please set \$SPL_VERSION"
    help
fi

if [ -z "$ZFS_VERSION" ]; then
    echo "No ZFS version defined. Please set \$ZFS_VERSION"
    help
fi

if [ -z "$DOCKER_REGISTRY" ]; then
    echo "No private registry set. Please set \$DOCKER_REGISTRY"
    help
fi

if [ -z "$KBUILDER_IMAGE" ]; then
    echo "No image name for CoreOS kernel modules builder. Please set \$KBUILDER_IMAGE"
    echo "Defaulting to: coreos/kmod-builder"
    KBUILDER_IMAGE="coreos/kmod-builder"
fi

if [ -z "$ZFS_BUILDER_IMAGE" ]; then
    echo "No image name for ZFS kernel modules builder. Please set \$ZFS_BUILDER_IMAGE"
    echo "Defaulting to: coreos/zfs-builder"
    ZFS_BUILDER_IMAGE="coreos/zfs-builder"
fi

if [ -z "$ZFS_INJECTOR_IMAGE" ]; then
    echo "No image name for ZFS kernel modules injectorPlease set \$ZFS_INJECTOR_IMAGE"
    echo "Defaulting to: coreos/zfs-builder"
    ZFS_INJECTOR_IMAGE="coreos/zfs-injector"
fi

if [ -z "$ZFS_BIN_IMAGE" ]; then
    echo "No image name for ZFS binaries only image. Please set \$ZFS_BIN_IMAGE"
    echo "Defaulting to: coreos/zfs-bin"
    ZFS_BIN_IMAGE="coreos/zfs-bin"
fi

KBUILDER_TAG="$COREOS_VERSION"
KBUILDER_TARGET="$DOCKER_REGISTRY/$KBUILDER_IMAGE:$KBUILDER_TAG"

ZFS_TAG="$COREOS_VERSION-$SPL_VERSION-$ZFS_VERSION"
ZFS_BUILDER_TARGET="$DOCKER_REGISTRY/$ZFS_BUILDER_IMAGE:$COREOS_VERSION"

ZFS_INJECTOR_TARGET="$DOCKER_REGISTRY/$ZFS_INJECTOR_IMAGE:$ZFS_TAG"

ZFS_BIN_TARGET="$DOCKER_REGISTRY/$ZFS_BIN_IMAGE:$ZFS_VERSION"

# Check if we've built it already
#if curl -q "https://$DOCKER_REGISTRY/v2/$ZFS_INJECTOR_IMAGE/tags/list" |grep -q "$ZFS_TAG"; then
#    echo "Kernel builder image $KBUILDER_TARGET already present, skipping!"
#    exit 0
#fi

mkdir pkg 2>/dev/null

if [ ! -f "pkg/spl-${ZFS_VERSION}.tar.gz" ]; then
  wget -N -Opkg/spl-${ZFS_VERSION}.tar.gz https://github.com/zfsonlinux/spl/archive/spl-${ZFS_VERSION}.tar.gz
fi

if [ ! -f "pkg/zfs-${ZFS_VERSION}.tar.gz" ]; then
  wget -N -Opkg/zfs-${ZFS_VERSION}.tar.gz https://github.com/zfsonlinux/zfs/releases/download/zfs-${ZFS_VERSION}/zfs-${ZFS_VERSION}.tar.gz
fi

mkdir dockerfiles 2>/dev/null || true

BUILDER_DOCKERFILE="Dockerfile.builder.template"
if [ -z "$BUILDER_NOPKG" ]; then
  BUILDER_DOCKERFILE="Dockerfile.builder.nopkg.template"
fi

sed -re "s|<DOCKER_FROM>|$KBUILDER_TARGET|" $BUILDER_DOCKERFILE > dockerfiles/Dockerfile.builder.$COREOS_VERSION
docker build --no-cache -f dockerfiles/Dockerfile.builder.$COREOS_VERSION -t $ZFS_BUILDER_TARGET .
if [ $? -ne 0 ]; then
  echo "Failed to build builers: $?"
  exit 1
fi

BIN_DIR="binaries/$COREOS_VERSION-$SPL_VERSION-$ZFS_VERSION"
mkdir $BIN_DIR 2>/dev/null
MOD_DIR="modules/$COREOS_VERSION-$SPL_VERSION-$ZFS_VERSION"
mkdir $MOD_DIR 2>/dev/null
DOCKER_OPTS="-e=COREOS_VERSION=$COREOS_VERSION -e=SPL_VERSION=${SPL_VERSION} -e=ZFS_VERSION=$ZFS_VERSION -v=$(pwd)/$BIN_DIR:/bin_dir -v=$(pwd)/$MOD_DIR:/mod_dir -v=$(pwd)/pkg:/pkg"

docker run $DOCKER_OPTS $ZFS_BUILDER_TARGET build
if [ $? -ne 0 ]; then
  echo "Failed to build modules: $?"
  exit 1
fi

sed -re "s|<VERSION>|$ZFS_TAG|" Dockerfile.injector.template > dockerfiles/Dockerfile.injector.$ZFS_TAG
docker build -f dockerfiles/Dockerfile.injector.$ZFS_TAG -t $ZFS_INJECTOR_TARGET .
if [ $? -ne 0 ]; then
  echo "Failed to build injector: $?"
  exit 1
fi
docker push $ZFS_INJECTOR_TARGET

sed -re "s|<VERSION>|$ZFS_TAG|" Dockerfile.bin.template > dockerfiles/Dockerfile.bin.$ZFS_VERSION
docker build -f dockerfiles/Dockerfile.bin.$ZFS_VERSION -t $ZFS_BIN_TARGET .
if [ $? -ne 0 ]; then
  echo "Failed to build injector: $?"
  exit 1
fi
docker push $ZFS_BIN_TARGET

