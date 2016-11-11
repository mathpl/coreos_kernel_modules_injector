#!/bin/bash
set -e

if [ "$1" != "build" ]; then
  exec "$@"
fi

cd /usr/src
tar xvzf /pkg/spl-${SPL_VERSION}.tar.gz
tar xvzf /pkg/zfs-${ZFS_VERSION}.tar.gz

echo "Building SPL..."
cd spl-spl-${SPL_VERSION}
./autogen.sh
kver=$(ls /usr/lib/modules/)
./configure --with-linux=/usr/src/linux --with-linux-obj=/usr/lib/modules/$kver/build --with-config=kernel
make clean
make -j2
make install

echo "Building ZFS..."
cd /usr/src/zfs-${ZFS_VERSION}
./configure --with-linux-obj=/usr/lib/modules/$kver/build --enable-static
make clean
make -j2
make install

echo "Build complete"
cp -va /usr/local/bin /bin_dir/
cp -va /usr/local/sbin /bin_dir/
cp -va /usr/local/lib64 /bin_dir/
cp -va /lib/modules /mod_dir/
chmod uo+rw -R /bin_dir
