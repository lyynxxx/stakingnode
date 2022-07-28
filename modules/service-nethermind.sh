#!/bin/bash

## Install dependencies
zypper in libsnappy1
zypper in glibc-devel
  or
yum install -y glibc-devel bzip2-devel libzstd

# Link libraries
sudo ln -s `find /usr/lib64/ -type f -name "libbz2.so.1*"` /usr/lib64/libbz2.so.1.0  #Leap15.4 got this
sudo ln -s `find /usr/lib64/ -type f -name "libsnappy.so.1*"` /usr/lib64/libsnappy.so


## Add service users - nethermind
## Chack latest version and link here: https://github.com/nethermind/nethermind/releases
groupadd nethermind
useradd --system -g nethermind --no-create-home --shell /bin/false nethermind
mkdir -p /opt/nethermind/app
mkdir -p /opt/nethermind/data
cd /opt/tmp
curl -kL https://nethdev.blob.core.windows.net/builds/nethermind-linux-amd64-1.13.4-3e5972c.zip --output nethermind-linux-amd64-1.13.4-3e5972c.zip
unzip nethermind-linux-amd64-1.13.4-3e5972c.zip -d /opt/nethermind/app
chown -R nethermind:nethermind /opt/nethermind

-------------
Build (RHEL):

git clone https://github.com/NethermindEth/nethermind --recursive
cd nethermind/src/Nethermind

mkdir BUILD

dotnet build Nethermind.sln -c Release -o /opt/builder/BUILD/

--------------------------------

openssl rand -hex 32 | tr -d "\n" > "/opt/tmp/jwtsecret"
chown nethermind:nethermind /opt/tmp/jwtsecret
chmod 644 /opt/tmp/jwtsecret

[Unit]
Description=Nethermind Node
Documentation=https://docs.nethermind.io
After=network.target

[Service]
User=nethermind
Group=nethermind
EnvironmentFile=/opt/nethermind/.env
WorkingDirectory=/opt/nethermind/app
ExecStart=/opt/nethermind/app/Nethermind.Runner --datadir /opt/nethermind/data --Init.WebSocketsEnabled true --JsonRpc.WebSocketsPort 8545 --JsonRpc.JwtSecretFile /opt/tmp/jwtsecret
Restart=on-failure
LimitNOFILE=1000000

[Install]
WantedBy=default.target

-------------------------
.env 

NETHERMIND_CONFIG="mainnet_pruned"
NETHERMIND_JSONRPCCONFIG_ENABLED=true
NETHERMIND_JSONRPCCONFIG_HOST="0.0.0.0"
NETHERMIND_HEALTHCHECKSCONFIG_ENABLED="true"



--------------
## Limits:

## echo "nethermind soft nofile 100000" > /etc/security/limits.d/nethermind.conf
## echo "nethermind hard nofile 100000" >> /etc/security/limits.d/nethermind.conf

## FW:
## nft add rule inet my_table tcp_chain tcp dport 30303 counter accept
## nft add rule inet my_table udp_chain udp dport 30303 counter accept
## nft list ruleset > /etc/sysconfig/nftables.conf




https://docs.nethermind.io/nethermind/first-steps-with-nethermind/manage-nethermind-with-systemd
https://github.com/ObolNetwork/charon-distributed-validator-node

https://www.youtube.com/watch?v=4tVLDpp2P0I

ETH rewards and penalities
https://twitter.com/EthereumPools/status/1547619229175668736

mev-boost
https://www.youtube.com/watch?v=sZYJiLxp9ow&t=1139s