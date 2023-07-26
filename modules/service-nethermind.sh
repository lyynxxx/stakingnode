#!/bin/bash

# https://github.com/NethermindEth/nethermind
pacman -S snappy


mkdir -p /opt/tmp
cd /opt/tmp

URL=$(curl -s https://api.github.com/repos/NethermindEth/nethermind/releases/latest | jq -r ".assets[] | select(.name) | .browser_download_url" | grep linux-x64 )
VER=$(curl -s https://api.github.com/repos/NethermindEth/nethermind/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
curl -L $URL --output nethermind.$VER.zip


groupadd nethermind
useradd --system -g nethermind --no-create-home --shell /bin/false nethermind
mkdir -p /opt/nethermind/app
mkdir -p /opt/nethermind/data
mkdir -p /opt/nethermind/tmp

# NOT TYPO! -o sets the output directory, NO SPACE!
7z x nethermind.1.19.3.zip -o/opt/nethermind/app/

KEY=$(openssl rand -hex 32 | tr -d "\n" )
echo ${KEY} > /opt/nethermind/jwtsecret
chmod 644 /opt/nethermind/jwtsecret
chown -R nethermind:nethermind /opt/nethermind

ln -s `find /usr/lib64/ -type f -name "libbz2.so.1*"` /usr/lib64/libbz2.so.1.0



cd /opt/nethermind/app
export DOTNET_BUNDLE_EXTRACT_BASE_DIR=/opt/nethermind/tmp


## Limits:

echo "nethermind soft nofile 8192" > /etc/security/limits.d/nethermind.conf
echo "nethermind hard nofile 8192" >> /etc/security/limits.d/nethermind.conf

## FW open
nft add rule inet my_table tcp_chain tcp dport 30303 counter accept
nft add rule inet my_table udp_chain udp dport 30303 counter accept
nft list ruleset > /etc/sysconfig/nftables.conf

