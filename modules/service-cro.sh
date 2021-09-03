#!/bin/bash

## Add service users - CRO Fullnode on testnet
groupadd sentry
mkdir -p /opt/cro-sentry/bin
mkdir -p /opt/cro-sentry/tmp
mkdir -p /opt/cro-sentry/.chain-maind/config
useradd --system --no-create-home -g sentry --shell /bin/false sentry
cd /opt/cro-sentry/tmp
curl -LOJk https://github.com/crypto-org-chain/chain-main/releases/download/v1.1.0/chain-main_1.1.0_Linux_x86_64.tar.gz
tar -zxvf chain-main_1.1.0_Linux_x86_64.tar.gz
mv /opt/cro-sentry/tmp/bin/chain-maind /opt/cro-sentry/bin/
rm chain-main_1.1.0_Linux_x86_64.tar.gz
chown -R sentry:sentry /opt/cro-sentry

## https://chain.crypto.com/docs/getting-started/croeseid-testnet.html
su - sentry -s /bin/bash -c  "/opt/cro-sentry/bin/chain-maind init DarkStar --home /opt/cro-sentry/.chain-maind --chain-id=crypto-org-chain-mainnet-1"
sleep 2
curl -ks https://raw.githubusercontent.com/crypto-org-chain/mainnet/main/crypto-org-chain-mainnet-1/genesis.json > /opt/cro-sentry/.chain-maind/config/genesis.json
chmod 640 /opt/cro-sentry/.chain-maind/config/genesis.json
chmod 750 /opt/cro-sentry/bin/chain-maind
sed -i.bak -E 's#^(minimum-gas-prices[[:space:]]+=[[:space:]]+)""$#\1"0.025basecro"#' /opt/cro-sentry/.chain-maind/config/app.toml
sleep 2
sed -i.bak -E 's#^(seeds[[:space:]]+=[[:space:]]+).*$#\1"8dc1863d1d23cf9ad7cbea215c19bcbe8bf39702@p2p.baaa7e56-cc71-4ae4-b4b3-c6a9d4a9596a.cryptodotorg.bison.run:26656,494d860a2869b90c458b07d4da890539272785c9@p2p.fabc23d9-e0a1-4ced-8cd7-eb3efd6d9ef3.cryptodotorg.bison.run:26656,8a7922f3fb3fb4cfe8cb57281b9d159ca7fd29c6@p2p.aef59b2a-d77e-4922-817a-d1eea614aef4.cryptodotorg.bison.run:26656,dc2540dabadb8302da988c95a3c872191061aed2@p2p.7d1b53c0-b86b-44c8-8c02-e3b0e88a4bf7.cryptodotorg.herd.run:26656,33b15c14f54f71a4a923ac264761eb3209784cf2@p2p.0d20d4b3-6890-4f00-b9f3-596ad3df6533.cryptodotorg.herd.run:26656,d2862ef8f86f9976daa0c6f59455b2b1452dc53b@p2p.a088961f-5dfd-4007-a15c-3a706d4be2c0.cryptodotorg.herd.run:26656,87c3adb7d8f649c51eebe0d3335d8f9e28c362f2@seed-0.crypto.org:26656,e1d7ff02b78044795371beb1cd5fb803f9389256@seed-1.crypto.org:26656,2c55809558a4e491e9995962e10c026eb9014655@seed-2.crypto.org:26656"#' /opt/cro-sentry/.chain-maind/config/config.toml
sed -i.bak -E 's#^(create_empty_blocks_interval[[:space:]]+=[[:space:]]+).*$#\1"5s"#' /opt/cro-sentry/.chain-maind/config/config.toml
sed -i.bak -E "s/^external_addre.*/external_address\ =\ \"94.199.178.148:26656\"/g" /opt/cro-sentry/.chain-maind/config/config.toml
sleep 2
su - sentry -s /bin/bash -c "/opt/cro-sentry/bin/chain-maind --home /opt/cro-sentry/.chain-maind tendermint show-node-id > /opt/cro-sentry/.sentrynode-id"
su - sentry -s /bin/bash -c "/opt/cro-sentry/bin/chain-maind --home /opt/cro-sentry/.chain-maind validate-genesis > /opt/cro-sentry/.genesis_init_state"
#increate tx timeout!!!
sed -i.bak 's/^timeout_broadcast_tx_commit.*/timeout_broadcast_tx_commit = "20s"/g' /opt/cro-sentry/.chain-maind/config/config.toml
chown -R sentry:sentry /opt/cro-sentry

mv /tmp/kickstart/eth2nodes/opensuse/etc/systemd/system/cronode.service /etc/systemd/system/
chown root:root /etc/systemd/system/cronode.service
chmod 644 /etc/systemd/system/cronode.service

systemctl daemon-reload
systemctl enable cronode