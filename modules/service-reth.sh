mkdir -p /opt/tmp
cd /opt/tmp

curl -Lk https://github.com/paradigmxyz/reth/releases/download/v0.2.0-beta.3/reth-v0.2.0-beta.3-x86_64-unknown-linux-gnu.tar.gz --output reth-v0.2.0-beta.3-x86_64-unknown-linux-gnu.tar.gz

groupadd reth
useradd --system -g reth --no-create-home --shell /bin/false reth
mkdir -p /opt/staking/clients/reth/app
mkdir -p /opt/staking/datadir/reth
chown -R reth:reth /opt/staking/clients/reth
chown -R reth:reth /opt/staking/datadir/reth
