#!/bin/bash

# sudo docker run -ti --privileged -v=/usr/share/oem/:/target/oem -v=/opt:/target/opt jcr.io/coreos/zfs-injector:1185.3.0-0.6.5.8-0.6.5.8 inject

depmod
modprobe dahdi
