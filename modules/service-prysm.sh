#!/bin/bash

## Download Prysm client apps
cd /opt/tmp
curl https://raw.githubusercontent.com/prysmaticlabs/prysm/master/prysm.sh --output prysm.sh && chmod +x prysm.sh
./prysm.sh beacon-chain --download-only
./prysm.sh validator --download-only
mkdir /root/bin
cp prysm.sh /root/bin/
chmod +x /root/bin/prysm.sh


## Add service users - BEACON
groupadd beacon
useradd --system -g beacon --no-create-home --shell /bin/false beacon
mkdir -p /opt/beacon-chain/data
mkdir -p /opt/beacon-chain/bin
cp /opt/tmp/dist/beacon-chain*amd64 /opt/beacon-chain/bin/beacon-chain
chown -R beacon:beacon /opt/beacon-chain


## Add service users - VALIDATOR (LOCK LATER, NEEDS SHELL TO IMPORT SIGNING KEY)
groupadd validator
useradd --system -g validator --no-create-home --shell /bin/false validator
mkdir -p /opt/validator/data
mkdir -p /opt/validator/bin
cp /opt/tmp/dist/validator*amd64 /opt/validator/bin/validator
touch /opt/validator/.wpwd
chown -R validator:validator /opt/validator

## Copy service files
cp /tmp/kickstart/eth2nodes/opensuse/etc/systemd/system/beacon.service /etc/systemd/system/
cp /tmp/kickstart/eth2nodes/opensuse/etc/systemd/system/validator.service /etc/systemd/system/
chown root:root /etc/systemd/system/beacon.service
chmod 644 /etc/systemd/system/beacon.service
chown root:root /etc/systemd/system/validator.service
chmod 644 /etc/systemd/system/validator.service

rn -rf /opt/tmp/*