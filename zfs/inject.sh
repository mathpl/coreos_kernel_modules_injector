#!/bin/bash

# sudo docker run -ti --privileged -v=/usr/share/oem/:/target/oem -v=/opt:/target/opt jcr.io/coreos/zfs-injector:1185.3.0-0.6.5.8-0.6.5.8 /inject.sh

mkdir /target/bin /target/sbin /target/lib64 2>/dev/null
cp -a /usr/local/bin/* /target/bin/
cp -a /usr/local/sbin/* /target/sbin/
cp -a /usr/local/lib64/* /target/lib64

depmod
modprobe zfs
