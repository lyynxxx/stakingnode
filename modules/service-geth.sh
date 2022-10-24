#!/bin/bash

## Add service users - Geth – Camaron (v1.10.19) 
## Chack latest version and link here: https://geth.ethereum.org/downloads/
groupadd geth
useradd --system -g geth -d /opt/goethereum/ --shell /bin/false geth
mkdir -p /opt/goethereum/bin
mkdir -p /opt/goethereum/data
mkdir -p /opt/goethereum/data-ancient

cd /opt/goethereum
curl https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.10.25-69568c55.tar.gz --output geth-linux-amd64-1.10.25-69568c55.tar.gz
tar xf geth-linux-amd64-1.10.25-69568c55.tar.gz
mv geth-linux-amd64-1.10.25-69568c55/geth /opt/goethereum/bin/
rm -rf geth-linux-amd64-1.10.25-69568c55*
chmod 755 /opt/goethereum
chown -R geth:geth /opt/goethereum

cp /tmp/kickstart/stakingnode/os/openSUSE/etc/systemd/system/geth.service /etc/systemd/system/
chown root:root /etc/systemd/system/geth.service
chmod 644 /etc/systemd/system/geth.service

systemctl enable geth


## Prune: 
## switch the beacon chain to Infura and stop geth, then:
## Don't forget to increase open files limits if not set in /etc/security/limits !!!! otherwise prune will crash and you can resync from zero...
## use screen, so you can disconnect while pruning:
## screen -L -Logfile /tmp/screen -S prune
## su - geth -s /bin/bash -c "/opt/goethereum/bin/geth --datadir /opt/goethereum/data --datadir.ancient /opt/goethereum/data-ancient snapshot prune-state"

## Limits:

echo "geth soft nofile 8192" > /etc/security/limits.d/geth.conf
echo "geth hard nofile 8192" >> /etc/security/limits.d/geth.conf

## FW:
## nft add rule inet my_table tcp_chain tcp dport 30303 counter accept
## nft add rule inet my_table udp_chain udp dport 30303 counter accept
## nft list ruleset > /etc/sysconfig/nftables.conf
