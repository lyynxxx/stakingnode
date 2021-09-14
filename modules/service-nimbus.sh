#!/bin/bash

## Download Lighthouse client apps from latest branch
mkdir -p /opt/tmp
cd /opt/tmp
LATEST=$(curl --silent "https://api.github.com/repos/sigp/lighthouse/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
curl -L https://github.com/sigp/lighthouse/releases/download/$LATEST/lighthouse-$LATEST-x86_64-unknown-linux-gnu.tar.gz -o lighthouse-$LATEST-x86_64-unknown-linux-gnu.tar.gz
tar -xf lighthouse-$LATEST-x86_64-unknown-linux-gnu.tar.gz


## Add service users - Lighthouse Beacon Chain
groupadd lightbc
useradd --system -g lightbc --no-create-home --shell /bin/false lightbc
mkdir -p /opt/lighthouse-bc/data
mkdir -p /opt/lighthouse-bc/bin
cp /opt/tmp/lighthouse /opt/lighthouse-bc/bin/
chown -R lightbc:lightbc /opt/lighthouse-bc

## Add service users - Lighthouse validator client
groupadd lightvc
useradd --system -g lightvc --no-create-home --shell /bin/false lightvc
mkdir -p /opt/lighthouse-vc/data
mkdir -p /opt/lighthouse-vc/bin
cp /opt/tmp/lighthouse /opt/lighthouse-vc/bin/
touch /opt/lighthouse-vc/.wpwd
chown -R lightvc:lightvc /opt/lighthouse-vc


## Copy service files
cp /tmp/kickstart/stakingnode/openSUSE/etc/systemd/system/beacon.service /etc/systemd/system/
cp /tmp/kickstart/stakingnode/openSUSE/etc/systemd/system/validator.service /etc/systemd/system/
chown root:root /etc/systemd/system/beacon.service
chmod 644 /etc/systemd/system/beacon.service
chown root:root /etc/systemd/system/validator.service
chmod 644 /etc/systemd/system/validator.service


## cleanup
rm -rf /opt/tmp/*
