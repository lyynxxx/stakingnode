#!/bin/bash
## https://docs.teku.consensys.net/en/latest/HowTo/Get-Started/Run-Teku/
## You can run Teku as a beacon node and validator in a single process, or as separate processes.


## OpenJDK 18 GA:
## https://jdk.java.net/18/
cd /opt/tmp
curl -k https://download.java.net/java/GA/jdk18.0.1.1/65ae32619e2f40f3a9af3af1851d6e19/2/GPL/openjdk-18.0.1.1_linux-x64_bin.tar.gz --output openjdk-18.0.1.1_linux-x64_bin.tar.gz
mkdir -p /opt/jdk
tar -zxf openjdk-18.0.1.1_linux-x64_bin.tar.gz -C /opt/jdk/
chown -R root:root /opt/jdk
chmod -R 755 /opt/jdk


## Download Teku
cd /opt/tmp
LATEST=$(curl -sL https://api.github.com/repos/ConsenSys/teku/releases/latest | jq -r ".tag_name")
curl -L https://artifacts.consensys.net/public/teku/raw/names/teku.tar.gz/versions/$LATEST/teku-$LATEST.tar.gz --output teku-$LATEST.tar.gz
tar -xf teku-$LATEST.tar.gz


## Add service users - BEACON
groupadd teku
useradd --system -g teku --no-create-home --shell /bin/false teku
mkdir -p /opt/teku/data
mkdir -p /opt/teku/bin
mkdir -p /opt/teku/lib
mkdir -p /opt/teku/tmp
mkdir -p /opt/teku/validators/keys
mkdir -p /opt/teku/validators/pwds
cp -a /opt/tmp/teku-$LATEST/bin/teku /opt/teku/bin/
cp -a /opt/tmp/teku-$LATEST/lib /opt/teku/
chown -R teku:teku /opt/teku

cp /tmp/kickstart/stakingnode/os/openSUSE/etc/systemd/system/teku.service /etc/systemd/system/
chown root:root /etc/systemd/system/teku.service
chmod 644 /etc/systemd/system/teku.service

## Limits:

echo "teku soft nofile 10000" > /etc/security/limits.d/teku.conf
echo "teku hard nofile 10000" >> /etc/security/limits.d/teku.conf


## FW:
nft add rule inet my_table tcp_chain tcp dport 9000 counter accept
nft add rule inet my_table udp_chain udp dport 9000 counter accept
nft list ruleset > /etc/sysconfig/nftables.conf

## Exit:
## https://docs.teku.consensys.net/HowTo/Voluntary-Exit/
## /opt/teku/bin voluntary-exit --beacon-node-api-endpoint=http://127.0.0.1:5051 --validator-keys=/opt/teku/validators/keys/validator_1e9f2a.json:/opt/teku/validators/pwds/validator_1e9f2a.txt
