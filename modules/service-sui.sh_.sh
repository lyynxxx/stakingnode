zypper in cmake gcc libopenssl-1_1-devel gcc-c++ clang13 libclang13

groupadd sui
useradd -m --system -g sui -d /opt/sui/ --shell /bin/false sui

su - sui -s /bin/bash -c "export TMP=/opt/sui/tmp/; export TEMP=/opt/sui/tmp/; export TMPDIR=/opt/sui/tmp/; curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"

su - sui -s /bin/bash -c "source /opt/sui/.cargo/env; rustup update"
nft add rule inet my_table tcp_chain tcp dport 9000 counter accept
nft add rule inet my_table tcp_chain tcp dport 9000 counter accept
nft add rule inet my_table tcp_chain tcp dport 9184 counter accept
nft add rule inet my_table tcp_chain tcp dport 9184 counter accept
nft list ruleset > /etc/sysconfig/nftables.conf

su - sui -s /bin/bash -c "source /opt/sui/.cargo/env; cargo install --locked --git https://github.com/MystenLabs/sui.git --branch devnet sui sui-node"

su - sui -s /bin/bash -c 'source /opt/sui/.cargo/env; cargo install --git https://github.com/move-language/move move-analyzer --features "address20" '

su - sui -s /bin/bash -c "source /opt/sui/.cargo/env; sui client active-address "

Config file ["/opt/sui/.sui/sui_config/client.yaml"] doesn't exist, do you want to connect to a Sui full node server [yN]?y
Sui full node server url (Default to Sui DevNet if not specified) :
Select key scheme to generate keypair (0 for ed25519, 1 for secp256k1):
0
Generated new keypair for address with scheme "ed25519" [0xf566256c39a8c3043f8950f8d3f2d5f8cb439712]
Secret Recovery Phrase : [delay owner clever model penalty try water oblige ask ill use dad]
0xf566256c39a8c3043f8950f8d3f2d5f8cb439712

!faucet 0xf566256c39a8c3043f8950f8d3f2d5f8cb439712


git clone https://github.com/MystenLabs/sui.git --branch devnet
cp crates/sui-config/data/fullnode-template.yaml fullnode.yaml

curl -fLJO https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob



su - sui -s /bin/bash -c "source /opt/sui/.cargo/env; sui-node --config-path /opt/sui/.sui/sui_config/fullnode.yaml"