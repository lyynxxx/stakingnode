#!/bin/bash
## https://docs.teku.consensys.net/en/latest/HowTo/Get-Started/Run-Teku/
## Download Teku
cd /opt/tmp
curl -L https://artifacts.consensys.net/public/teku/raw/names/teku.tar.gz/versions/22.4.0/teku-22.4.0.tar.gz --output teku-22.4.0.tar.gz
tar -xf teku-22.4.0.tar.gz



## Add service users - BEACON
groupadd beacon
useradd --system -g beacon -d /opt/beacon --shell /bin/false beacon
mkdir -p /opt/beacon/data
mkdir -p /opt/beacon/bin
mkdir -p /opt/beacon/lib
cp -a /opt/tmp/teku-22.4.0/bin/teku /opt/beacon/bin/
cp -a /opt/tmp/teku-22.4.0/lib /opt/beacon/
chown -R beacon:beacon /opt/beacon

cat > /etc/systemd/system/beacon.service << EOF
[Unit]
Description=Lighthouse Beacon Node
After=network.target

[Service]
Type=simple
User=beacon
Restart=always
RestartSec=5
LimitNOFILE=5120
LimitNPROC=5120
Environment="JAVA_OPTS=-Xmx4g"
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