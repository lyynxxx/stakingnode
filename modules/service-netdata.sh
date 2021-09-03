#!/bin/bash
# Netdata
cd /opt/tmp
curl -SsO https://my-netdata.io/kickstart-static64.sh
sh ./kickstart-static64.sh --stable-channel --dont-wait
sleep 2
rm -rf /opt/tmp/*
