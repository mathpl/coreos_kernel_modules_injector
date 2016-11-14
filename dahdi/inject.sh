#!/bin/bash

# sudo docker run -ti --privileged jcr.io/coreos/dahdi-injector:1185.3.0-2.10.2 inject

depmod
for m in "dahdi_transcode dahdi_voicebus dahdi crc_ccitt xpp wcb4xxp wctdm wcfxo wctdm24xxp wcte11xp wct1xxp wcte12xp wct4xxp"
do
    modprobe $m
done
