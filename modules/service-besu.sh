#!/bin/bash

## Add service users - besu
## Chack latest version and link here: https://besu.ethereum.org/downloads/
## Bonsai engine: https://consensys.net/blog/news/test-staking-ahead-of-the-merge-with-improved-bonsai-tries-state-storage/
curl -k https://hyperledger.jfrog.io/artifactory/besu-binaries/besu/22.4.1/besu-22.4.1.tar.gz --output besu-22.4.1.tar.gz

groupadd besu
useradd --system -g besu -d /opt/besu/ --shell /bin/false besu
mkdir -p /opt/besu/bin
mkdir -p /opt/besu/data
mkdir -p /opt/besu/config
## copy compiled binary
chown -R besu:besu /opt/besu
mv /tmp/kickstart/stakingnode/os/openSUSE/etc/systemd/system/besu.service /etc/systemd/system/
chown root:root /etc/systemd/system/besu.service
chmod 644 /etc/systemd/system/besu.service

systemctl enable besu


## FW:
## nft add rule inet my_table my_tcp_chain tcp dport 30303 counter accept
## nft add rule inet my_table my_udp_chain udp dport 30303 counter accept

## besu --data-path=/opt/besu/data --genesis-file=/tmp/besu_genesis.json --network-id=1337802