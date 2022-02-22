#!/bin/bash

## Add service users - openethereum
## Chack latest version and link here: https://github.com/openethereum/openethereum/releases
groupadd openethereum
useradd --system -g openethereum -d /opt/openethereum --shell /bin/false openethereum
mkdir -p /opt/openethereum/bin
mkdir -p /opt/openethereum/data
cd /opt/openethereum

curl -L https://github.com/openethereum/openethereum/releases/download/v3.3.4/openethereum-linux-v3.3.4.zip --output openethereum-linux-v3.3.4.zip
unzip openethereum-linux-v3.3.4.zip
mv openethereum /opt/openethereum/bin/
chmod +x /opt/openethereum/bin/openethereum
rm -rf openethereum-linux-v3.3.4.zip
chown -R openethereum:openethereum /opt/openethereum

mv /tmp/kickstart/stakingnode/os/openSUSE/etc/systemd/system/openethereum.service /etc/systemd/system/
chown root:root /etc/systemd/system/openethereum.service
chmod 644 /etc/systemd/system/openethereum.service

systemctl enable openethereum


#/opt/openethereum/bin/openethereum -d /opt/openethereum/data --chain xdai --no-warp 