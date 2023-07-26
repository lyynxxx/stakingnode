#!/bin/bash

## Download Prysm client apps
cd /opt/tmp
curl https://raw.githubusercontent.com/prysmaticlabs/prysm/master/prysm.sh --output prysm.sh && chmod +x prysm.sh
./prysm.sh prysm-bc --download-only
./prysm.sh validator --download-only
mkdir /root/bin
cp prysm.sh /root/bin/
chmod +x /root/bin/prysm.sh


## Add service users - BEACON
groupadd beacon
useradd --system -g beacon -d /opt/prysm-bc --shell /bin/false beacon
mkdir -p /opt/prysm-bc/data
mkdir -p /opt/prysm-bc/bin
cp /opt/tmp/dist/beacon-chain*amd64 /opt/prysm-bc/bin/prysm-bc
chown -R beacon:beacon /opt/prysm-bc


## Add service users - VALIDATOR (LOCK LATER, NEEDS SHELL TO IMPORT SIGNING KEY)
groupadd validator
useradd --system -g validator -d /opt/prysm-val --shell /bin/false validator
mkdir -p /opt/prysm-val/data
mkdir -p /opt/prysm-val/bin
cp /opt/tmp/dist/validator*amd64 /opt/prysm-val/bin/validator
touch /opt/prysm-val/.wpwd
chown -R validator:validator /opt/prysm-val

## Copy service files
cp /tmp/kickstart/stakingnode/os/openSUSE/etc/systemd/system/beacon-prysm.service /etc/systemd/system/beacon.service
cp /tmp/kickstart/stakingnode/os/openSUSE/etc/systemd/system/validator-prysm.service /etc/systemd/system/validator.service
chown root:root /etc/systemd/system/beacon.service
chmod 644 /etc/systemd/system/beacon.service
chown root:root /etc/systemd/system/validator.service
chmod 644 /etc/systemd/system/validator.service

rn -rf /opt/tmp/*

echo "prysm soft nofile 10000" > /etc/security/limits.d/prysm.conf
echo "prysm hard nofile 10000" >> /etc/security/limits.d/prysm.conf

## FW:
nft add rule inet my_table tcp_chain tcp dport 13000 counter accept
nft add rule inet my_table udp_chain udp dport 12000 counter accept
nft list ruleset > /etc/sysconfig/nftables.conf

## Import:
## Create wallet
##su - validator -s /bin/bash -c "/opt/prysm-val/bin/validator wallet create --wallet-dir=/opt/prysm-val/.wllt --wallet-password-file=/opt/prysm-val/.wpwd --keymanager-kind=imported --accept-terms-of-use"

## Import key (!! use keystore- prefix !!)
##su - validator -s /bin/bash -c "/opt/prysm-val/bin/validator accounts import --keys-dir=/opt/tmp/keystore-val.json --wallet-dir=/opt/prysm-val/.wllt --wallet-password-file=/opt/prysm-val/.wpwd"

## List accounts
##su - validator -s /bin/bash -c "/opt/prysm-val/bin/validator accounts list --wallet-dir=/opt/prysm-val/.wllt --wallet-password-file=/opt/prysm-val/.wpwd"
