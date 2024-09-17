#!/bin/bash
## https://docs.teku.consensys.net/en/latest/HowTo/Get-Started/Run-Teku/
## You can run Teku as a beacon node and validator in a single process, or as separate processes.

## Get JAVA/openjdk 21
## Arch
## pacman -S extra/jre21-openjdk-headless 

## Suse
## zypper in java-21-openjdk-headless

## Download Teku latest  --  assuming jq and curl are installed
mkdir -p /opt/tmp
cd /opt/tmp
LATEST=$(curl -sL https://api.github.com/repos/ConsenSys/teku/releases/latest | jq -r ".tag_name")
curl -L https://artifacts.consensys.net/public/teku/raw/names/teku.tar.gz/versions/$LATEST/teku-$LATEST.tar.gz --output teku-$LATEST.tar.gz
tar -xf teku-$LATEST.tar.gz


## Add service user, create folder structure, copy files and set permissions
groupadd teku
useradd --system -g teku --no-create-home --shell /bin/false teku
mkdir -p /opt/staking/datadir/teku
mkdir -p /opt/staking/clients/teku/bin
mkdir -p /opt/staking/clients/teku/lib
mkdir -p /opt/staking/clients/teku/tmp
mkdir -p /opt/staking/clients/teku/validators/keys
mkdir -p /opt/staking/clients/teku/validators/pwds

cp -a /opt/tmp/teku-$LATEST/bin/teku /opt/staking/clients/teku/bin/
cp -a /opt/tmp/teku-$LATEST/lib /opt/staking/clients/teku/
chown -R teku:teku /opt/staking/clients/teku
chown -R teku:teku /opt/staking/datadir/teku

cp /tmp/kickstart/stakingnode/os/common/systemd/system/teku.service /etc/systemd/system/
chown root:root /etc/systemd/system/teku.service
chmod 644 /etc/systemd/system/teku.service


## Cleanup
rm -rf /opt/tmp/*


## Limits:
mkdir -p /etc/security/limits.d   # if not present (Arch)
echo "teku soft nofile 12000" > /etc/security/limits.d/teku.conf
echo "teku hard nofile 12000" >> /etc/security/limits.d/teku.conf


## FW:
nft add rule inet my_table tcp_chain tcp dport 9000 counter accept
nft add rule inet my_table udp_chain udp dport 9000 counter accept
nft list ruleset > /etc/sysconfig/nftables.conf ## <--- SUSE
nft list ruleset > /etc/nftables.conf ## <-- Arch

## Exit:
## https://docs.teku.consensys.net/HowTo/Voluntary-Exit/
## !!! /tmp noexec fluffs this
## su - teku -s /bin/bash
## /opt/staking/clients/teku/bin/teku voluntary-exit --logging=DEBUG --data-base-path=/opt/staking/datadir/teku --beacon-node-api-endpoint=http://127.0.0.1:5052 --validator-keys=/opt/staking/clients/teku/validators/keys/keystore-m_12381_3600_0_0_0-1709842902.json:/opt/staking/clients/teku/validators/pwds/keystore-m_12381_3600_0_0_0-1709842902.txt

## Move validator to backup node...
## Move validator - create package
7z -mhc=on -mhe=on -pPasswordHere a -r /opt/tmp/teku.7z /opt/staking/datadir/teku/validator/slashprotection /opt/staking/clients/teku/validators
chmod 644 /opt/tmp/teku.7z

## Move validator - extract package
7z x /opt/tmp/teku.7z -pPasswordHere
cp -ar /opt/tmp/validators /opt/staking/clients/teku/validators
cp -ar /opt/tmp/slashprotection /opt/staking/datadir/teku/validator/slashprotection
chown -R teku:teku /opt/staking/datadir/teku
chown -R teku:teku /opt/staking/clients/teku

## Enable validator keys, change systemd service
sed -i 's/eth1-deposit-contract-max-request-size=1500/--eth1-deposit-contract-max-request-size=1500 \\/g' /etc/systemd/system/teku.service
LINE=$(grep -n 'validator-keys' /etc/systemd/system/teku.service | cut -d ":" -f 1)
sed -i "${LINE}s/^.//" /etc/systemd/system/teku.service
systemctl daemon-reload

## Disable validator keys, change systemd service
sed -i 's/eth1-deposit-contract-max-request-size=1500 \\/eth1-deposit-contract-max-request-size=1500/g' /etc/systemd/system/teku.service
LINE=$(grep -n 'validator-keys' /etc/systemd/system/teku.service | cut -d ":" -f 1)
sed -i "${LINE}s/^./#/" /etc/systemd/system/teku.service
systemctl daemon-reload
