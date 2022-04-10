#!/bin/bash

## Download Lighthouse client apps from latest branch
mkdir -p /opt/tmp
cd /opt/tmp
LATEST=$(curl --silent "https://api.github.com/repos/sigp/lighthouse/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
curl -L https://github.com/sigp/lighthouse/releases/download/$LATEST/lighthouse-$LATEST-x86_64-unknown-linux-gnu-portable.tar.gz -o lighthouse-$LATEST-x86_64-unknown-linux-gnu-portable.tar.gz
tar -xf lighthouse-$LATEST-x86_64-unknown-linux-gnu-portable.tar.gz


## Add service users - Lighthouse Beacon Chain
groupadd beacon
useradd --system -g beacon -d /opt/beacon-chain --shell /bin/false beacon
mkdir -p /opt/beacon/data
mkdir -p /opt/beacon/bin
cp /opt/tmp/lighthouse /opt/beacon/bin/
chmod 755 /opt/beacon/bin/lighthouse
chown -R beacon:beacon /opt/beacon

## Add service users - Lighthouse validator client
groupadd validator
useradd --system -g validator -d /opt/validator --shell /bin/bash validator
mkdir -p /opt/validator/data
mkdir -p /opt/validator/bin
cp /opt/tmp/lighthouse /opt/validator/bin/
chmod 755 /opt/validator/bin/lighthouse
chown -R validator:validator /opt/validator


## Copy service files
cp /tmp/kickstart/stakingnode/openSUSE/etc/systemd/system/beacon-lh.service /etc/systemd/system/beacon.service
cp /tmp/kickstart/stakingnode/openSUSE/etc/systemd/system/validator-lh.service /etc/systemd/system/validator.service
chown root:root /etc/systemd/system/beacon.service
chmod 644 /etc/systemd/system/beacon.service
chown root:root /etc/systemd/system/validator.service
chmod 644 /etc/systemd/system/validator.service


## FW open
#nft add rule inet my_table my_tcp_chain tcp dport 9001 counter accept
#nft add rule inet my_table my_udp_chain udp dport 9001 counter accept
#nft list ruleset > /etc/sysconfig/nftables.conf

## Import validator key and lock user shell
# /opt/validator/bin/lighthouse --network mainnet account validator import --directory /opt/validator/import --datadir /opt/validator/data
# usermod --shell /bin/false validator

## cleanup
rm -rf /opt/tmp/*