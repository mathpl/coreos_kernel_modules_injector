#!/bin/bash
set -e

if [ "$1" != "build" ]; then
  exec "$@"
fi

echo "Checking out Dahdi..."
cd /usr/src
git clone https://github.com/asterisk/dahdi-linux.git
cd dahdi-linux
git checkout $DAHDI_VERSION

echo "Building Dahdi..."
export KVERS=$(ls /usr/lib/modules/)
make firmware-download
make -j2
make install

echo "Build complete"

rsync -va /lib/modules /mod_dir --exclude "source" --exclude "build"
