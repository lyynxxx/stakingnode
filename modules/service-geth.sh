#!/bin/bash

## Add service users - GETH
groupadd geth
useradd --system -g geth --no-create-home --shell /bin/false geth
mkdir -p /opt/goethereum/bin
mkdir -p /opt/goethereum/data
cd /opt/goethereum
curl https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.10.1-c2d2f4ed.tar.gz --output geth-linux-amd64-1.10.1-c2d2f4ed.tar.gz
tar xf geth-linux-amd64-1.10.1-c2d2f4ed.tar.gz
mv geth-linux-amd64-1.10.1-c2d2f4ed/geth /opt/goethereum/bin/
rm -rf geth-linux-amd64-1.10.1-c2d2f4ed*
chown -R geth:geth /opt/goethereum

mv /tmp/kickstart/eth2nodes/opensuse/etc/systemd/system/geth.service /etc/systemd/system/
chown root:root /etc/systemd/system/geth.service
chmod 644 /etc/systemd/system/geth.service

systemctl enable geth