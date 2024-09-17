#!/bin/bash

## Bonsai engine: https://consensys.net/blog/news/test-staking-ahead-of-the-merge-with-improved-bonsai-tries-state-storage/
## "We recommend using snap sync with Bonsai for the fastest sync and lowest storage requirements."

## https://besu.hyperledger.org/en/stable/HowTo/Get-Started/Installation-Options/Install-Binaries/
## Hyperledger Besu supports:
## Java 11+. We recommend using at least Java 17 because that will be the minimum requirement in the next Besu version series.

mkdir -p /opt/tmp
cd /opt/tmp
LATEST=$(curl -sL https://api.github.com/repos/hyperledger/besu/releases/latest | jq -r .tag_name)
curl -L https://github.com/hyperledger/besu/releases/download/$LATEST/besu-$LATEST.tar.gz --output besu-$LATEST.tar.gz
tar -zxf besu-$LATEST.tar.gz -C /opt/tmp/

## Get JAVA/openjdk 21
## Arch
## pacman -S extra/jre21-openjdk-headless 

## Suse
## zypper in java-21-openjdk-headless


## Add service users - besu
groupadd besu
useradd --system -g besu --no-create-home --shell /bin/false besu
mkdir -p /opt/staking/datadir/besu
mkdir -p /opt/staking/clients/besu/tmp

mv /opt/tmp/besu-$LATEST/* /opt/staking/clients/besu/
rm -rf /opt/tmp/besu-$LATEST

chown -R besu:besu /opt/staking/datadir/besu
chown -R besu:besu /opt/staking/clients/besu

mkdir -p /opt/staking/secret
KEY=$(openssl rand -hex 32 | tr -d "\n" )
echo ${KEY} > /opt/staking/secret/jwtsecret
chmod 644 /opt/staking/secret/jwtsecret

mv /tmp/kickstart/stakingnode/os/common/systemd/system/besu.service /etc/systemd/system/
chown root:root /etc/systemd/system/besu.service
chmod 644 /etc/systemd/system/besu.service

systemctl enable besu

## Limits
mkdir -p /etc/security/limits.d
echo "besu soft nofile 12000" > /etc/security/limits.d/besu.conf
echo "besu hard nofile 12000" >> /etc/security/limits.d/besu.conf

## Good to know: --Xplugin-rocksdb-high-spec-enabled allows Besu increased database performance. Recommended for machines with minimum 16GB of RAM or more.

## FW:
nft add rule inet my_table tcp_chain tcp dport 30303 counter accept
nft add rule inet my_table udp_chain udp dport 30303 counter accept
nft list ruleset > /etc/sysconfig/nftables.conf
