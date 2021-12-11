#!/bin/bash

## Add service users - GETH
## Chack latest version and link here: https://geth.ethereum.org/downloads/
groupadd geth
useradd --system -g geth --no-create-home --shell /bin/false geth
mkdir -p /opt/goethereum/bin
mkdir -p /opt/goethereum/data
cd /opt/goethereum
curl https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.10.13-7a0c19f8.tar.gz --output geth-linux-amd64-1.10.13-7a0c19f8.tar.gz
tar xf geth-linux-amd64-1.10.13-7a0c19f8.tar.gz
mv geth-linux-amd64-1.10.13-7a0c19f8/geth /opt/goethereum/bin/
rm -rf geth-linux-amd64-1.10.13-7a0c19f8*
chown -R geth:geth /opt/goethereum

mv /tmp/kickstart/stakingnode/openSUSE/etc/systemd/system/geth.service /etc/systemd/system/
chown root:root /etc/systemd/system/geth.service
chmod 644 /etc/systemd/system/geth.service

systemctl enable geth
