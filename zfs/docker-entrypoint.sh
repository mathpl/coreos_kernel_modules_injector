#!/bin/bash
set -e

if [ -S "/var/run/docker.sock" ]; then
    echo "Need /var/run/docker.sock available."
    exit 1
fi

if [ -z "$COREOS_VERSION" ]; then
    echo "No CoreOS version defined. Please set \$COREOS_VERSION"
    exit 1
fi

if [ -z "$ZFS_VERSION" ]; then
    echo "No SPL/ZFS version defined. Please set \$ZFS_VERSION"
    exit 1
fi

if [ -z "$DOCKER_TARGET" ]; then
    echo "No docker image name defined defined. Please set \$DOCKER_TARGET"
    exit 1
fi

wget -N -O/pkg/spl-${ZFS_VERSION}.tar.gz https://github.com/zfsonlinux/spl/archive/spl-${ZFS_VERSION}.tar.gz
wget -N -O/pkg/zfs-${ZFS_VERSION}.tar.gz https://github.com/zfsonlinux/zfs/releases/download/zfs-${ZFS_VERSION}/zfs-${ZFS_VERSION}.tar.gz

cd /usr/src
tar xvzf /pkg/spl-${ZFS_VERSION}.tar.gz
tar xvzf /pkg/zfs-${ZFS_VERSION}.tar.gz

cd spl-spl-${ZFS_VERSION}
./autogen.sh
kver=$(ls /usr/lib/modules/)
./configure --with-linux=/usr/src/linux --with-linux-obj=/usr/lib/modules/$kver/build --with-config=kernel
make clean
make -j2
make install

cd /usr/src/zfs-${ZFS_VERSION}
./configure
make clean
make -j2
make install

