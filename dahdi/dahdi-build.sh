#!/bin/bash
set -e

if [ "$1" != "build" ]; then
  exec "$@"
fi

cd /usr/src
tar xvzf /pkg/dahdi-linux-${DAHDI_VERSION}.tar.gz

echo "Building Dahdi..."
cd dahdi-linux-${DAHDI_VERSION}
export KVERS=$(ls /usr/lib/modules/|head -1)
make -j2
make install

echo "Build complete"

rsync -va /lib/modules /mod_dir --exclude "source" --exclude "build"
