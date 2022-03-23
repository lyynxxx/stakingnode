#!/bin/bash

## Add service users - GETH
## Chack latest version and link here: https://geth.ethereum.org/downloads/
groupadd geth
useradd --system -g geth -d /opt/goethereum/ --shell /bin/false geth
mkdir -p /opt/goethereum/bin
mkdir -p /opt/goethereum/data
mkdir -p /opt/goethereum/data-ancient

cd /opt/goethereum
curl https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.10.16-20356e57.tar.gz --output geth-linux-amd64-1.10.16-20356e57.tar.gz
tar xf geth-linux-amd64-1.10.16-20356e57.tar.gz
mv geth-linux-amd64-1.10.16-20356e57/geth /opt/goethereum/bin/
rm -rf geth-linux-amd64-1.10.16-20356e57*
chmod 755 /opt/goethereum
chown -R geth:geth /opt/goethereum

mv /tmp/kickstart/stakingnode/os/openSUSE/etc/systemd/system/geth.service /etc/systemd/system/
chown root:root /etc/systemd/system/geth.service
chmod 644 /etc/systemd/system/geth.service

systemctl enable geth


## Prune: 
## switch the beacon chain to Infura and stop geth, then:
## su - geth -s /bin/bash -c "/opt/goethereum/bin/geth --datadir /opt/goethereum/data snapshot prune-state"

## FW:
## nft add rule inet my_table my_tcp_chain tcp dport 30303 counter accept
## nft add rule inet my_table my_udp_chain udp dport 30303 counter accept
## nft list ruleset > /etc/sysconfig/nftables.conf
