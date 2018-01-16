#!/bin/bash
set -e

if [ "$1" != "build" ]; then
  exec "$@"
fi

cd /pkg

echo "Building Dahdi..."
export KVERS=$(ls /usr/lib/modules/)
make -j2
make install

echo "Build complete"

rsync -va /lib/modules /mod_dir --exclude "source" --exclude "build"
