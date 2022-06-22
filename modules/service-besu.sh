#!/bin/bash


## Chack latest version and link here: https://besu.ethereum.org/downloads/
## Bonsai engine: https://consensys.net/blog/news/test-staking-ahead-of-the-merge-with-improved-bonsai-tries-state-storage/

## https://besu.hyperledger.org/en/stable/HowTo/Get-Started/Installation-Options/Install-Binaries/
## Hyperledger Besu supports:
## Java 11+. We recommend using at least Java 17 because that will be the minimum requirement in the next Besu version series. You can install Java using brew install openjdk. Alternatively, you can manually install the Java JDK.

cd /opt/tmp
curl -k https://hyperledger.jfrog.io/artifactory/besu-binaries/besu/22.4.3/besu-22.4.3.tar.gz --output besu-22.4.3.tar.gz

## OpenJDK 18 GA:
## https://jdk.java.net/18/
cd /opt/tmp
curl -k https://download.java.net/java/GA/jdk18.0.1.1/65ae32619e2f40f3a9af3af1851d6e19/2/GPL/openjdk-18.0.1.1_linux-x64_bin.tar.gz --output openjdk-18.0.1.1_linux-x64_bin.tar.gz
mkdir -p /opt/jdk
mkdir tar -zxf openjdk-18.0.1.1_linux-x64_bin.tar.gz -C /opt/jdk/
chmod -R 755 /opt/jdk


## Add service users - besu
groupadd besu
useradd --system -g besu -d /opt/besu/ --shell /bin/false besu
mkdir -p /opt/besu/bin
mkdir -p /opt/besu/data
mkdir -p /opt/besu/config
mkdir -p /opt/besu/tmp
## extract binary and libs
tar -zxf /opt/tmp/besu-22.4.3.tar.gz -C /opt/tmp/
mv /opt/tmp/besu-22.4.3/* /opt/besu/
rm -rf /opt/tmp/besu-22.4.3
## copy compiled binary
chown -R besu:besu /opt/besu
mv /tmp/kickstart/stakingnode/os/openSUSE/etc/systemd/system/besu.service /etc/systemd/system/
chown root:root /etc/systemd/system/besu.service
chmod 644 /etc/systemd/system/besu.service

systemctl enable besu


## FW:
## nft add rule inet my_table tcp_chain tcp dport 30303 counter accept
## nft add rule inet my_table udp_chain udp dport 30303 counter accept

## besu --data-path=/opt/besu/data --genesis-file=/tmp/besu_genesis.json --network-id=1337802
## su - besu -s /bin/bash -c "/opt/jdk/jdk-18.0.1.1/bin/java --version"


