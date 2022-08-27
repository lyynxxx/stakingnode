#!/bin/bash
# Netdata

## if /tmp has noexec
export TMPDIR=/opt/tmp

cd /opt/tmp
mkdir /opt/tmp/netdata_tmp
curl -SsO https://my-netdata.io/kickstart-static64.sh
sh ./kickstart-static64.sh --stable-channel --dont-wait --claim-token xxxxxxxxxxxxxxxx --claim-rooms xxxxxxxxxxxxxx --claim-url https://app.netdata.cloud
sleep 2
chown netdata:netdata /opt/tmp/netdata_tmp
sed -i 's/NETDATA_TMPDIR=.*/NETDATA_TMPDIR="/opt/tmp/netdata_tmp"/g' /opt/netdata/etc/netdata/.environment
rm -rf /opt/tmp/*
