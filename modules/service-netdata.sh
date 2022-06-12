#!/bin/bash
# Netdata
cd /opt/tmp
curl -SsO https://my-netdata.io/kickstart-static64.sh
sh ./kickstart-static64.sh --stable-channel --dont-wait --claim-token xxxxxxxxxxxxxxxx --claim-rooms xxxxxxxxxxxxxx --claim-url https://app.netdata.cloud
sleep 2
rm -rf /opt/tmp/*
