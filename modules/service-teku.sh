#!/bin/bash
## https://docs.teku.consensys.net/en/latest/HowTo/Get-Started/Run-Teku/
## You can run Teku as a beacon node and validator in a single process, or as separate processes.


## OpenJDK 18 GA:
## https://jdk.java.net/18/
cd /opt/tmp
curl -k https://download.java.net/java/GA/jdk18.0.1.1/65ae32619e2f40f3a9af3af1851d6e19/2/GPL/openjdk-18.0.1.1_linux-x64_bin.tar.gz --output openjdk-18.0.1.1_linux-x64_bin.tar.gz
mkdir -p /opt/jdk
tar -zxf openjdk-18.0.1.1_linux-x64_bin.tar.gz -C /opt/jdk/
chown -R root:root /opt/jdk
chmod -R 755 /opt/jdk


## Download Teku
cd /opt/tmp
LATEST=$(curl -sL https://api.github.com/repos/ConsenSys/teku/releases/latest | jq -r ".tag_name")
curl -L https://artifacts.consensys.net/public/teku/raw/names/teku.tar.gz/versions/$LATEST/teku-$LATEST.tar.gz --output teku-$LATEST.tar.gz
tar -xf teku-$LATEST.tar.gz


## Add service users - BEACON
groupadd teku
useradd --system -g teku --no-create-home --shell /bin/false teku
mkdir -p /opt/teku/data
mkdir -p /opt/teku/bin
mkdir -p /opt/teku/lib
mkdir -p /opt/teku/tmp
mkdir -p /opt/teku/validators/keys
mkdir -p /opt/teku/validators/pwds
cp -a /opt/tmp/teku-$LATEST/bin/teku /opt/teku/bin/
cp -a /opt/tmp/teku-$LATEST/lib /opt/teku/
chown -R teku:teku /opt/teku

cat > /etc/systemd/system/teku.service << EOF
[Unit]
Description=Teku ETH Client
After=network.target

[Service]
Type=simple
User=teku
Restart=always
RestartSec=5
LimitNOFILE=5120
LimitNPROC=5120
Environment="JAVA_OPTS=-Xmx4g -Djava.io.tmpdir=/opt/teku/tmp -Dio.netty.native.workdir=/opt/teku/tmp"
Environment="JAVA_HOME=/opt/jdk/jdk-18.0.1.1"
Environment="TMP=/opt/teku/tmp"
Environment="TEMP=/opt/teku/tmp"
Environment="TMPDIR=/opt/teku/tmp"
ExecStart=/opt/teku/bin/teku --network=prater --ee-endpoint=http://127.0.0.1:8551 --ee-jwt-secret-file "/opt/goethereum/jwtsecret" --data-base-path=/opt/teku/data --metrics-enabled --rest-api-enabled --validator-keys=/opt/teku/validators/keys:/opt/teku/validators/pwds --validators-graffiti="Mom's Old-Fashioned Robot Oil" --validators-proposer-default-fee-recipient 0x452D545Ea9Fcf6564370Ae418bcE49404994Bd3f 
InaccessibleDirectories=/home /var
ReadOnlyDirectories=/etc /usr
PrivateTmp=yes
NoNewPrivileges=yes
PrivateDevices=true
ProtectControlGroups=true
ProtectHome=true
ProtectKernelTunables=true
ProtectSystem=full
RestrictSUIDSGID=true

[Install]
WantedBy=multi-user.target

EOF


---------------


## Limits:

## echo "teku soft nofile 100000" > /etc/security/limits.d/teku.conf
## echo "teku hard nofile 100000" >> /etc/security/limits.d/teku.conf


## FW:
## nft add rule inet my_table tcp_chain tcp dport 9000 counter accept
## nft add rule inet my_table udp_chain udp dport 9000 counter accept
## nft list ruleset > /etc/sysconfig/nftables.conf