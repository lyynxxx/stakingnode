#!/bin/bash

## Chack latest version and link here: https://geth.ethereum.org/downloads/
LATEST=$(curl --silent "https://api.github.com/repos/ethereum/go-ethereum/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
RELEASE_URL="https://geth.ethereum.org/downloads"
FILE="https://gethstore.blob.core.windows.net/builds/geth-linux-amd64[a-zA-Z0-9./?=_%:-]*.tar.gz"
BINARIES_URL="$(curl -s $RELEASE_URL | grep -Eo $FILE | head -1)"

## Add service users - Geth
groupadd geth
useradd --system -g geth --no-create-home --shell /bin/false geth
mkdir -p /opt/staking/clients/goethereum/bin
mkdir -p /opt/staking/datadir/geth
mkdir -p /opt/staking/datadir/geth-ancient

## Create JWT token
mkdir -p /opt/staking/secret
KEY=$(openssl rand -hex 32 | tr -d "\n" )
echo ${KEY} > /opt/staking/secret/jwtsecret

## Get Geth, extract and copy to app folder
curl $BINARIES_URL --output /opt/tmp/geth-linux-amd64-$LATEST.tar.gz
tar -xf /opt/tmp/geth-linux-amd64-$LATEST.tar.gz -C /opt/tmp/ --strip-components 1
mv /opt/tmp/geth /opt/staking/clients/goethereum/bin/
rm -rf /opt/tmp/*

## Fix folder permissions
chmod 750 /opt/staking/clients/goethereum
chmod 750 /opt/staking/datadir/geth
chmod 750 /opt/staking/datadir/geth-ancient

chown -R geth:geth /opt/staking/clients/goethereum
chown -R geth:geth /opt/staking/datadir/geth
chown -R geth:geth /opt/staking/datadir/geth-ancient

## Get systemd service and enable the service
cp /tmp/kickstart/stakingnode/os/common/etc/systemd/system/geth.service /etc/systemd/system/
chown root:root /etc/systemd/system/geth.service
chmod 644 /etc/systemd/system/geth.service

systemctl enable geth


## Limits:

echo "geth soft nofile 12000" > /etc/security/limits.d/geth.conf
echo "geth hard nofile 12000" >> /etc/security/limits.d/geth.conf

## FW:
nft add rule inet my_table tcp_chain tcp dport 30303 counter accept
nft add rule inet my_table udp_chain udp dport 30303 counter accept
nft list ruleset > /etc/sysconfig/nftables.conf
