#!/bin/bash

## Add service users - GETH
## Chack latest version and link here: https://geth.ethereum.org/downloads/
groupadd geth
useradd --system -g geth --no-create-home --shell /bin/false geth
mkdir -p /opt/goethereum/bin
mkdir -p /opt/goethereum/data
cd /opt/goethereum
curl https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.10.15-8be800ff.tar.gz --output geth-linux-amd64-1.10.15-8be800ff.tar.gz
tar xf geth-linux-amd64-1.10.15-8be800ff.tar.gz
mv geth-linux-amd64-1.10.15-8be800ff/geth /opt/goethereum/bin/
rm -rf geth-linux-amd64-1.10.15-8be800ff*
chown -R geth:geth /opt/goethereum

mv /tmp/kickstart/stakingnode/os/openSUSE/etc/systemd/system/geth.service /etc/systemd/system/
chown root:root /etc/systemd/system/geth.service
chmod 644 /etc/systemd/system/geth.service

systemctl enable geth


## Prune: 
## switch the beacon chain to Infura and stop geth, then:
## su - geth -s /bin/bash -c "/opt/goethereum/bin/geth --datadir /opt/goethereum/data snapshot prune-state"