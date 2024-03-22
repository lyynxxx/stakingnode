#!/bin/bash

# https://github.com/NethermindEth/nethermind
pacman -S snappy
ln -s `find /usr/lib64/ -type f -name "libbz2.so.1*"` /usr/lib64/libbz2.so.1.0

mkdir -p /opt/tmp
cd /opt/tmp

URL=$(curl -s https://api.github.com/repos/NethermindEth/nethermind/releases/latest | jq -r ".assets[] | select(.name) | .browser_download_url" | grep linux-x64 )
VER=$(curl -s https://api.github.com/repos/NethermindEth/nethermind/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
curl -L $URL --output nethermind.$VER.zip


groupadd nethermind
useradd --system -g nethermind --no-create-home --shell /bin/false nethermind
mkdir -p /opt/staking/clients/nethermind/app
mkdir -p /opt/staking/datadir/nethermind
mkdir -p /opt/staking/clients/nethermind/tmp

# NOT TYPO! -o sets the output directory, NO SPACE!
7z x nethermind.$VER.zip -o/opt/staking/clients/nethermind/app

mkdir -p /opt/staking/secret
KEY=$(openssl rand -hex 32 | tr -d "\n" )
echo ${KEY} > /opt/staking/secret/jwtsecret
chmod 644 /opt/staking/secret/jwtsecret
chown -R nethermind:nethermind /opt/staking/clients/nethermind
chown -R nethermind:nethermind /opt/staking/datadir/nethermind

cp /tmp/kickstart/stakingnode/os/common/systemd/system/nethermind-fullprune.service /etc/systemd/system/nethermind.service
chown root:root /etc/systemd/system/nethermind.service
chmod 644 /etc/systemd/system/nethermind.service

## Limits:
## ARCH -> mkdir -p /etc/security/limits.d/
echo "nethermind soft nofile 12000" > /etc/security/limits.d/nethermind.conf
echo "nethermind hard nofile 12000" >> /etc/security/limits.d/nethermind.conf

## FW open
nft add rule inet my_table tcp_chain tcp dport 30303 counter accept
nft add rule inet my_table udp_chain udp dport 30303 counter accept
nft list ruleset > /etc/sysconfig/nftables.conf

