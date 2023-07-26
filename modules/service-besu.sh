#!/bin/bash


## Chack latest version and link here: https://besu.ethereum.org/downloads/
## Bonsai engine: https://consensys.net/blog/news/test-staking-ahead-of-the-merge-with-improved-bonsai-tries-state-storage/
## "We recommend using snap sync with Bonsai for the fastest sync and lowest storage requirements."

## https://besu.hyperledger.org/en/stable/HowTo/Get-Started/Installation-Options/Install-Binaries/
## Hyperledger Besu supports:
## Java 11+. We recommend using at least Java 17 because that will be the minimum requirement in the next Besu version series.

cd /opt/tmp
curl -k https://hyperledger.jfrog.io/artifactory/besu-binaries/besu/23.4.0/besu-23.4.0.tar.gz --output besu-23.4.0.tar.gz

## Java JDK 17 LTS:
## https://www.oracle.com/java/technologies/downloads/#java17
## JDK 17 binaries are free to use in production and free to redistribute, at no cost, under the Oracle No-Fee Terms and Conditions.
## JDK 17 will receive updates under these terms, until September 2024, a year after the release of the next LTS.
cd /opt/tmp
curl -k https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.tar.gz --output jdk-17_linux-x64_bin.tar.gz
mkdir -p /opt/jdk
tar -zxf jdk-17_linux-x64_bin.tar.gz -C /opt/jdk/
chmod -R 755 /opt/jdk


## Add service users - besu
groupadd besu
useradd --system -g besu -d /opt/besu/ --shell /bin/false besu
mkdir -p /opt/besu/bin
mkdir -p /opt/besu/data
mkdir -p /opt/besu/config
mkdir -p /opt/besu/tmp
## extract binary and libs
tar -zxf /opt/tmp/besu-23.4.0.tar.gz -C /opt/tmp/
mv /opt/tmp/besu-23.4.0/* /opt/besu/
rm -rf /opt/tmp/besu-23.4.0
## copy compiled binary
chown -R besu:besu /opt/besu
mv /tmp/kickstart/stakingnode/os/openSUSE/etc/systemd/system/besu.service /etc/systemd/system/
chown root:root /etc/systemd/system/besu.service
chmod 644 /etc/systemd/system/besu.service

systemctl enable besu

echo "besu soft nofile 12000" > /etc/security/limits.d/besu.conf
echo "besu hard nofile 12000" >> /etc/security/limits.d/besu.conf

## Good to know: --Xplugin-rocksdb-high-spec-enabled allows Besu increased database performance. Recommended for machines with 16GB of RAM or more.

## FW:
## nft add rule inet my_table tcp_chain tcp dport 30303 counter accept
## nft add rule inet my_table udp_chain udp dport 30303 counter accept

## besu --data-path=/opt/besu/data --genesis-file=/tmp/besu_genesis.json --network-id=1337802
## su - besu -s /bin/bash -c "/opt/jdk/jdk-18.0.1.1/bin/java --version"

## Build from source
# https://wiki.hyperledger.org/display/BESU/Building+from+source
# pkg install nss libsodium gmake <--!!
#https://github.com/jemalloc/jemalloc/blob/dev/INSTALL.md