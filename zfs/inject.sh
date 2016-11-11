#!/bin/bash

# sudo docker run -ti --privileged -v=/usr/share/oem/:/target/oem -v=/opt:/target/opt jcr.io/coreos/zfs-injector:1185.3.0-0.6.5.8-0.6.5.8 inject

mkdir /target/opt/bin /target/opt/sbin 2>/dev/null
cp -a /binaries/bin/* /target/opt/bin/
cp -a /binaries/sbin/* /target/opt/sbin/
cp -a /binaries/lib64/ /target/oem/

depmod
modprobe zfs
