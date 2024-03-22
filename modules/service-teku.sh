#!/bin/bash
## https://docs.teku.consensys.net/en/latest/HowTo/Get-Started/Run-Teku/
## You can run Teku as a beacon node and validator in a single process, or as separate processes.

## Get JAVA, pref 17LTS Runtime Env only, no need for JDK...
## Arch
## pacman -S extra/jre17-openjdk-headless

## Suse
## zypper in java-17-openjdk-headless

## Download Teku
cd /opt/tmp
LATEST=$(curl -sL https://api.github.com/repos/ConsenSys/teku/releases/latest | jq -r ".tag_name")
curl -L https://artifacts.consensys.net/public/teku/raw/names/teku.tar.gz/versions/$LATEST/teku-$LATEST.tar.gz --output teku-$LATEST.tar.gz
tar -xf teku-$LATEST.tar.gz


## Add service users - BEACON
groupadd teku
useradd --system -g teku --no-create-home --shell /bin/false teku
mkdir -p /opt/staking/datadir/teku
mkdir -p /opt/staking/clients/teku/bin
mkdir -p /opt/staking/clients/teku/lib
mkdir -p /opt/staking/clients/teku/tmp
mkdir -p /opt/staking/clients/validators/keys
mkdir -p /opt/staking/clients/validators/pwds

cp -a /opt/tmp/teku-$LATEST/bin/teku /opt/staking/clients/teku/bin/
cp -a /opt/tmp/teku-$LATEST/lib /opt/staking/clients/teku/
chown -R teku:teku /opt/staking/clients/teku
chown -R teku:teku /opt/staking/datadir/teku

rm -rf /opt/tmp/*

cp /tmp/kickstart/stakingnode/os/common/systemd/system/teku.service /etc/systemd/system/
chown root:root /etc/systemd/system/teku.service
chmod 644 /etc/systemd/system/teku.service

## Limits:

echo "teku soft nofile 12000" > /etc/security/limits.d/teku.conf
echo "teku hard nofile 12000" >> /etc/security/limits.d/teku.conf


## FW:
nft add rule inet my_table tcp_chain tcp dport 9000 counter accept
nft add rule inet my_table udp_chain udp dport 9000 counter accept
nft list ruleset > /etc/sysconfig/nftables.conf

## Exit:
## https://docs.teku.consensys.net/HowTo/Voluntary-Exit/
## su - teku -s /bin/bash
## export JAVA_HOME=/opt/jdk/jdk-18.0.1.1
## export PATH=$JAVA_HOME/bin:$PATH
## /opt/teku/bin/teku voluntary-exit --beacon-node-api-endpoint=http://127.0.0.1:5051 --validator-keys=/opt/teku/validators/keys/keystore-m_12381_3600_1_0_0-1649489984.json:/opt/teku/validators/pwds/keystore-m_12381_3600_1_0_0-1649489984.txt
