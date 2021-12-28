#!/bin/bash

## Add service users - Taraxa
groupadd taraxa
useradd --system -g taraxa -d /opt/taraxa --shell /bin/false taraxa
mkdir -p /opt/taraxa/data
mkdir -p /opt/taraxa/.conf
## Copy - if you already have - the generated wallet/config file to /opt/taraxa/.conf and the binary to /opt/taraxa/bin
chown -R taraxa:taraxa /opt/taraxa
chmod 750 /opt/taraxa

#mv /tmp/kickstart/stakingnode/openSUSE/etc/systemd/system/taraxa.service /etc/systemd/system/
#chown root:root /etc/systemd/system/taraxa.service
#chmod 644 /etc/systemd/system/taraxa.service

usermod --add-subuids 200000-201000 --add-subgids 200000-201000 taraxa
# grep taraxa /etc/subuid /etc/subgid 
su - taraxa -s /bin/bash -c "podman pull docker.io/taraxa/taraxa-node"
su - taraxa -s /bin/bash -c "podman run -d -p 10002:10002 -p 10002:10002/udp --name=taraxa-node1 --mount type=bind,source=/opt/taraxa/.conf,target=/opt/taraxa_data/conf --mount type=bind,source=/opt/taraxa/data,target=/opt/taraxa_data/data docker.io/taraxa/taraxa-node taraxad --network-id 2 --wallet /opt/taraxa_data/conf/wallet.json --config /opt/taraxa_data/conf/testnet.json --data-dir /opt/taraxa_data/data --overwrite-config"
slep 10
su - taraxa -s /bin/bash -c "podman stop taraxa-node1"

## Add Firewall rules
#nft add rule inet my_table my_tcp_chain tcp dport 10002 accept
#nft add rule inet my_table my_udp_chain udp dport 10002 accept
#nft list ruleset > /etc/sysconfig/nftables.conf

#su - taraxa -s /bin/bash -c "podman run -d -p 10002:10002 -p 10002:10002/udp --name=taraxa-node1 --mount type=bind,source=/opt/taraxa/.conf,target=/opt/taraxa_data/conf --mount type=bind,source=/opt/taraxa/data,target=/opt/taraxa_data/data docker.io/taraxa/taraxa-node taraxad --network-id 2 --wallet /opt/taraxa_data/conf/wallet.json --config /opt/taraxa_data/conf/testnet.json --data-dir /opt/taraxa_data/data --overwrite-config"


## I will compile the binary instead of using the docker images.
## TODO: small VM
## Install Ubuntu Server 20LTS MINIMAL!!!! No need for gui. Disk requirements: ~50G (if we want to check the docker images too we need some space)
## Follow this guide: https://github.com/Taraxa-project/taraxa-node/blob/develop/doc/building.md
## It's copy-paste...

## Install one more python module:
## pip install eth_account

## After the binary is compiled generate new wallet and config:

# /home/YOURUSERNAME/taraxa-node/cmake-build/bin/taraxad --command config
# Configuration file does not exist at: /home/YOURUSERNAME/.taraxa/config.json. New config file will be generated
# Wallet file does not exist at: /home/YOURUSERNAME/.taraxa/wallet.json. New wallet file will be generated


## Proof of ownership: taraxa sign, check your wallet file for the following lines: node_secret, node_address
##  -- private_key = "0x{}".format(w['node_secret']), text = "0x{}".format(w['node_address']), account = text = "0x{}".format(w['node_secret'])
## run python in the CLI
#$ python3

#import json
#from eth_account import Account
#from eth_utils.curried import keccak
#account = Account.from_key(0x85096c68cab805e964c24a0ef406c71a641d102301857197d7b2d8cf77d615ea)
#text = "0x2fdc4badc80a53980003e5e606266fe0eb4381db"
#sig = account.signHash(keccak(hexstr=text))
#sig_hex = sig.signature.hex()
#print(sig_hex)

#Proof ow ownership:
#0x3bada8cd78d6abd36b46d41ee2c15d040a4f087c24bd064749b1754dc316ec167b6070fc4f4e46c5f0e70b5c2f5c2ca28fa840a5afd3e883107edd2c5cb8dd361c




podman run -d -p 10002:10002 -p 10002:10002/udp --name=taraxa-node1 --mount type=bind,source=/opt/sas300/podman-data/taraxa/.conf,target=/opt/taraxa_data/conf --mount type=bind,source=/opt/sas300/podman-data/taraxa/data,target=/opt/taraxa_data/data docker.io/taraxa/taraxa-node taraxad --network-id 2 --wallet /opt/taraxa_data/conf/wallet.json --config /opt/taraxa_data/conf/testnet.json --data-dir /opt/taraxa_data/data --overwrite-config