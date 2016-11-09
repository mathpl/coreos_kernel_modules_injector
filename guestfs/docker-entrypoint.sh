#!/bin/bash
set -e

if [ ! -S "/var/run/docker.sock" ]; then
    echo "Need /var/run/docker.sock available."
    exit 1
fi

if [ -z "$COREOS_CHANNEL" ]; then
    echo "No CoreOS channel defined. Please set \$COREOS_CHANNEL"
    exit 1
fi

if [ -z "$COREOS_VERSION" ]; then
    echo "No CoreOS version defined. Please set \$COREOS_VERSION"
    exit 1
fi

if [ -z "$COREOS_ARCH" ]; then
    echo "No CoreOS architecture defined. Defaulting to amd64-usr. Please set \$COREOS_ARCH"
    COREOS_ARCH="amd64-usr"
fi

if [ -z "$COREOS_DEV_TARGET" ]; then
    echo "No docker image name defined defined. Please set \$COREOS_DEV_TARGET"
    exit 1
fi

FILE="/images/coreos_developer_container.${COREOS_VERSION}.bin"
if [ ! -f "$FILE" ]; then
    wget -N -O$FILE https://$COREOS_CHANNEL.release.core-os.net/$COREOS_ARCH/$COREOS_VERSION/coreos_developer_container.bin.bz2

    echo "Uncompressing disk image..."
    bunzip2 -v -c /images/coreos_developer_container.${COREOS_VERSION}.bin.bz2 > /images/coreos_developer_container.${COREOS_VERSION}.bin
    echo done
fi

echo "Converting to docker image.."
guestfish --ro -a $FILE -m /dev/sda9 -- tar-out / - | docker import - $COREOS_DEV_TARGET
echo done
