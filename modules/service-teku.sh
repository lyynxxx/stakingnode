#!/bin/bash
## https://docs.teku.consensys.net/en/latest/HowTo/Get-Started/Run-Teku/
## You can run Teku as a beacon node and validator in a single process, or as separate processes.
## Download Teku
cd /opt/tmp
curl -L https://artifacts.consensys.net/public/teku/raw/names/teku.tar.gz/versions/22.6.0/teku-22.6.0.tar.gz --output teku-22.6.0.tar.gz
tar -xf teku-22.6.0.tar.gz

## OpenJDK 18 GA:
## https://jdk.java.net/18/
cd /opt/tmp
curl -k https://download.java.net/java/GA/jdk18.0.1.1/65ae32619e2f40f3a9af3af1851d6e19/2/GPL/openjdk-18.0.1.1_linux-x64_bin.tar.gz --output openjdk-18.0.1.1_linux-x64_bin.tar.gz
mkdir -p /opt/jdk
mkdir tar -zxf openjdk-18.0.1.1_linux-x64_bin.tar.gz -C /opt/jdk/
chmod -R 755 /opt/jdk

## Add service users - BEACON
groupadd beacon
useradd --system -g beacon -d /opt/beacon --shell /bin/false teku
mkdir -p /opt/beacon/data
mkdir -p /opt/beacon/bin
mkdir -p /opt/beacon/lib
mkdir -p /opt/beacon/tmp
cp -a /opt/tmp/teku-22.6.0/bin/teku /opt/beacon/bin/
cp -a /opt/tmp/teku-22.6.0/lib /opt/beacon/
chown -R teku:beacon /opt/beacon

cat > /etc/systemd/system/beacon.service << EOF
[Unit]
Description=Lighthouse Beacon Node
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
Environment="TMP=/opt/beacon/tmp"
Environment="TEMP=/opt/beacon/tmp"
Environment="TMPDIR=/opt/beacon/tmp"
ExecStart=/opt/beacon/bin/teku --eth1-endpoint=http://localhost:8545 --data-base-path=/opt/beacon/data --metrics-enabled --rest-api-enabled
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