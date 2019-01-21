#!/bin/sh
set -ex

if [ "$1" = "install" ]; then
        cd /target
        ls /src/*.tbz2 | while read i; do
                tar -jxvf $i --exclude ./usr/include*
        done
else
        exec "$@"
fi