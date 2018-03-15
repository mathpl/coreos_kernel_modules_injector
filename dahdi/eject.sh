#!/bin/bash

for m in dahdi dahdi_dynamic dahdi_dynamic_eth dahdi_dynamic_ethmf dahdi_dynamic_loc dahdi_echocan_jpah dahdi_echocan_kb1 dahdi_echocan_mg2 dahdi_echocan_sec dahdi_echocan_sec2 dahdi_transcode dahdi_vpmadt032_loader oct612x pciradio tor2 dahdi_voicebus wcaxx wcb4xxp wcfxo wct1xxp wct4xxp wctc4xxp wctdm wctdm24xxp wcte11xp wcte12xp wcte13xp wcte43x xpd_bri xpd_echo xpd_fxo xpd_fxs xpd_pri xpp xpp_usb
do
    rmmod $m
done
