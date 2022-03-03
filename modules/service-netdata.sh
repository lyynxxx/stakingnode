#!/bin/bash
# Netdata
cd /opt/tmp
curl -SsO https://my-netdata.io/kickstart-static64.sh
sh ./kickstart-static64.sh --stable-channel --dont-wait --claim-token uBzE_0GhdHu06hr2v7_vcDNkd8DByX36MYWW0Xvu59AipvgMc_wzTDCL3wKsdeAehiEzaDNCEMgoG8Dylx3nSATQIhdTS_trdQ9_xXVE07pYR_AhVjWFqGsjmFnWjJyfTe8VfOQ --claim-rooms f67f3b09-9e06-4f06-afa1-e65b0d5a2ffd --claim-url https://app.netdata.cloud
sleep 2
rm -rf /opt/tmp/*
