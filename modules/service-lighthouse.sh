#!/bin/bash

## Download Lighthouse client apps from latest branch
mkdir -p /opt/tmp
cd /opt/tmp
LATEST=$(curl --silent "https://api.github.com/repos/sigp/lighthouse/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
curl -L https://github.com/sigp/lighthouse/releases/download/$LATEST/lighthouse-$LATEST-x86_64-unknown-linux-gnu-portable.tar.gz -o lighthouse-$LATEST-x86_64-unknown-linux-gnu-portable.tar.gz
tar -xf lighthouse-$LATEST-x86_64-unknown-linux-gnu-portable.tar.gz


## Add service users - Lighthouse Beacon Chain
groupadd beacon
useradd --system -g beacon -d /opt/beacon-lh --shell /bin/false beacon
mkdir -p /opt/beacon-lh/data
mkdir -p /opt/beacon-lh/bin
cp /opt/tmp/lighthouse /opt/beacon-lh/bin/
chmod 755 /opt/beacon-lh/bin/lighthouse
chown -R beacon:beacon /opt/beacon-lh

## Add service users - Lighthouse validator client
groupadd validator
useradd --system -g validator -d /opt/validator-lh --shell /bin/false validator
mkdir -p /opt/validator-lh/data
mkdir -p /opt/validator-lh/bin
cp /opt/tmp/lighthouse /opt/validator-lh/bin/
chmod 755 /opt/validator-lh/bin/lighthouse
chown -R validator:validator /opt/validator-lh


## Copy service files
cp /tmp/kickstart/stakingnode/openSUSE/etc/systemd/system/beacon-lighthouse.service /etc/systemd/system/beacon.service
cp /tmp/kickstart/stakingnode/openSUSE/etc/systemd/system/validator-lighthouse.service /etc/systemd/system/validator.service
chown root:root /etc/systemd/system/beacon.service
chmod 644 /etc/systemd/system/beacon.service
chown root:root /etc/systemd/system/validator.service
chmod 644 /etc/systemd/system/validator.service



## Limits:

echo "beacon soft nofile 8192" > /etc/security/limits.d/beacon.conf
echo "beacon hard nofile 8192" >> /etc/security/limits.d/beacon.conf

## FW open
#nft add rule inet my_table tcp_chain tcp dport 9001 counter accept
#nft add rule inet my_table udp_chain udp dport 9001 counter accept
#nft list ruleset > /etc/sysconfig/nftables.conf

## Import validator key and lock user shell
# /opt/validator/bin/lighthouse --network mainnet account validator import --directory /opt/validator/import --datadir /opt/validator/data
# usermod --shell /bin/false validator

## cleanup
rm -rf /opt/tmp/*

<< comment
## Exit validator
https://lighthouse-book.sigmaprime.io/voluntary-exit.html

lighthouse --network kiln account validator exit --keystore /path/to/keystore --beacon-node http://localhost:5052
validator@kiln:~> bin/lighthouse --network kiln account validator exit --datadir /opt/validator/data/ --keystore /opt/validator/data/validators/0x87724d8c3869ae540f993302bda2365fe69cf9e82a2d426588aad9b729ceab4179c592c286fd98f6e4e8882a96e3d26b/keystore-m_12381_3600_0_0_0-1647042964.json --beacon-node http://127.0.0.1:5052
Running account manager for kiln network
validator-dir path: "/opt/validator/data/validators"

Enter the keystore password for validator in "/opt/validator/data/validators/0x87724d8c3869ae540f993302bda2365fe69cf9e82a2d426588aad9b729ceab4179c592c286fd98f6e4e8882a96e3d26b/keystore-m_12381_3600_0_0_0-1647042964.json":

Password is correct.

Publishing a voluntary exit for validator: 0x87724d8c3869ae540f993302bda2365fe69cf9e82a2d426588aad9b729ceab4179c592c286fd98f6e4e8882a96e3d26b

WARNING: THIS IS AN IRREVERSIBLE OPERATION

WARNING: WITHDRAWING STAKED ETH IS NOT CURRENTLY POSSIBLE

PLEASE VISIT https://lighthouse-book.sigmaprime.io/voluntary-exit.html TO MAKE SURE YOU UNDERSTAND THE IMPLICATIONS OF A VOLUNTARY EXIT.
Enter the exit phrase from the above URL to confirm the voluntary exit:
Exit my validator
Successfully validated and published voluntary exit for validator 0x87724d8c3869ae540f993302bda2365fe69cf9e82a2d426588aad9b729ceab4179c592c286fd98f6e4e8882a96e3d26b
Voluntary exit has been accepted into the beacon chain, but not yet finalized. Finalization may take several minutes or longer. Before finalization there is a low probability that the exit may be reverted.
Current epoch: 23130, Exit epoch: 23135, Withdrawable epoch: 23391
Please keep your validator running till exit epoch
Exit epoch in approximately 1920 secs
validator@kiln:~>


comment
