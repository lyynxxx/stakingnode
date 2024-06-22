#!/bin/bash

## Download Lighthouse client apps from latest branch - portable for X99, approx. 20% slower ( https://lighthouse-book.sigmaprime.io/installation-binaries.html )
mkdir -p /opt/tmp
cd /opt/tmp
LATEST=$(curl --silent "https://api.github.com/repos/sigp/lighthouse/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
##Portable, for older cpus
curl -L https://github.com/sigp/lighthouse/releases/download/$LATEST/lighthouse-$LATEST-x86_64-unknown-linux-gnu-portable.tar.gz -o lighthouse-$LATEST-x86_64-unknown-linux-gnu-portable.tar.gz
tar -xf lighthouse-$LATEST-x86_64-unknown-linux-gnu-portable.tar.gz

##Default, for newer cpus
curl -L https://github.com/sigp/lighthouse/releases/download/$LATEST/lighthouse-$LATEST-x86_64-unknown-linux-gnu.tar.gz -o lighthouse-$LATEST-x86_64-unknown-linux-gnu.tar.gz
tar -xf lighthouse-$LATEST-x86_64-unknown-linux-gnu.tar.gz

## Add service users - Lighthouse Beacon Chain
groupadd lighthouse
useradd --system -g lighthouse --no-create-home --shell /bin/false lighthouse
mkdir -p /opt/staking/datadir/lighthouse/beacon
mkdir -p /opt/staking/clients/lighthouse/bin

cp /opt/tmp/lighthouse /opt/staking/clients/lighthouse/bin/
chmod 755 /opt/staking/clients/lighthouse/bin/lighthouse
chown -R lighthouse:lighthouse /opt/staking/clients/lighthouse
chown -R lighthouse:lighthouse /opt/staking/datadir/lighthouse

## Add service users - Lighthouse validator client (will use the same binary)
groupadd validator
useradd --system -g validator --no-create-home --shell /bin/false validator
mkdir -p /opt/staking/datadir/lighthouse/validator
chown -R validator:validator /opt/staking/datadir/lighthouse/validator


## Copy service files
cp /tmp/kickstart/stakingnode/common/etc/systemd/system/beacon-lh.service /etc/systemd/system/lighthouse-bn.service
cp /tmp/kickstart/stakingnode/common/etc/systemd/system/validator-lh.service /etc/systemd/system/validator.service
chown root:root /etc/systemd/system/lighthouse-bn.service
chmod 644 /etc/systemd/system/lighthouse-bn.service
chown root:root /etc/systemd/system/validator.service
chmod 644 /etc/systemd/system/validator.service



## Limits:

echo "lighthouse soft nofile 8192" > /etc/security/limits.d/beacon.conf
echo "lighthouse hard nofile 8192" >> /etc/security/limits.d/beacon.conf

## FW open
nft add rule inet my_table tcp_chain tcp dport 9000 counter accept
nft add rule inet my_table udp_chain udp dport 9000 counter accept
nft list ruleset > /etc/sysconfig/nftables.conf

## Import validator key, even with locked shell
# su - validator -s /bin/bash
# /opt/validator/bin/lighthouse --network mainnet account validator import --directory /opt/validator-lh/import --datadir /opt/validator-lh/data


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


# su - validator -s /bin/bash
$/opt/validator-lh/bin/lighthouse --network mainnet account validator import --keystore /opt/validator-lh/validators.x/keys/keystore_xxxxxx.json --datadir /opt/validator-lh/data

comment

## From Lighthouse to Teku
/opt/validator-lh/bin/lighthouse account validator slashing-protection export /tmp/slashing-interchange-format-minimal-from-lh.json --datadir /opt/validator-lh/data


/opt/staking/clients/lighthouse/bin/lighthouse account validator slashing-protection export /tmp/slashing-interchange-format-minimal-from-lh.json --datadir /opt/staking/datadir/lighthouse/validator
/opt/staking/clients/teku/bin/teku slashing-protection import --data-path /opt/staking/datadir/teku --from=/tmp/slashing-interchange-format-minimal-from-lh.json


## From Teku to Lighihouse
/opt/staking/clients/teku/bin/teku slashing-protection export --data-path=/opt/staking/datadir/teku --to=/opt/tmp/slashing-interchange-format-minimal-from-teku.json
/opt/staking/clients/lighthouse/bin/lighthouse account validator slashing-protection import /opt/tmp/slashing-interchange-format-minimal.json --datadir /opt/validator-lh/data

{
  "metadata" : {
    "interchange_format_version" : "5",
    "genesis_validators_root" : "0x4b363db94e286120d76eb905340fdd4e54bfe9f06bf33ff6cf5ad27f511bfe95"
  },
  "data" : [ {
    "pubkey" : "0xade36fbec0b1819aa0947f1c1c8d12d1a4d7d4e4949b0bb0b2a9fe554c75b340a8ca246deb75554cbfe5695061f51fd0",
    "signed_blocks" : [ {
      "slot" : "6675956"
    } ],
    "signed_attestations" : [ {
      "source_epoch" : "211547",
      "target_epoch" : "211548"
    } ]
  } ]
}