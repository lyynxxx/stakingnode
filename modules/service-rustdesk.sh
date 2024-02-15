## RustDesk Relay server (Ubuntu/Debian)
## https://rustdesk.com/docs/en/self-host/rustdesk-server-oss/install/#set-up-your-own-server-instance-manually

## Firewall
##    TCP (21115, 21116, 21117,   Web client only --> 21118, 21119)
##    UDP (21116)

## Install prerequisites
apt install curl wget unzip tar dnsutils

## Get latest version zip archive
mkdir -p /opt/tmp
cd /opt/tmp
LATEST=$(curl --silent "https://api.github.com/repos/rustdesk/rustdesk-server/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
curl -L https://github.com/rustdesk/rustdesk-server/releases/download/$LATEST/rustdesk-server-linux-amd64.zip

## Create service user: rustdesk
groupadd rustdesk
useradd --system -g rustdesk -d /opt/rustdesk --shell /bin/false rustdesk

## Create folders and unzip latest archive
mkdir -p /opt/rustdesk
mkdir -p /opt/tmp/rustdesk
unzip /opt/tmp/rustdesk-server-linux-amd64.zip -d /opt/tmp/rustdesk
mv /opt/tmp/rustdesk/amd64/* /opt/rustdesk
chmod +x /opt/rustdesk/hbbs
chmod +x /opt/rustdesk/hbbr
chown -R rustdesk:rustdesk /opt/rustdesk
rm -rf /opt/tmp/rustdesk

mkdir -p /var/log/rustdesk/
chown -R rustdesk /var/log/rustdesk

## Systemd service files - signal server
cat > /etc/systemd/system/rustdesksignal.service << EOF
[Unit]
Description=Rustdesk Signal Server

[Service]
Type=simple
LimitNOFILE=1000000
ExecStart=/opt/rustdesk/hbbs -k _
WorkingDirectory=/opt/rustdesk/
User=rustdesk
Group=rustdesk
Restart=always
StandardOutput=append:/var/log/rustdesk/signalserver.log
StandardError=append:/var/log/rustdesk/signalserver.error
# Restart service after 10 seconds if node service crashes
RestartSec=10

[Install]
WantedBy=multi-user.target

EOF
## End service file

## Systemd service files - relay server
cat > /etc/systemd/system/rustdeskrelay.service << EOF
[Unit]
Description=Rustdesk Relay Server

[Service]
Type=simple
LimitNOFILE=1000000
ExecStart=/opt/rustdesk/hbbr -k _
WorkingDirectory=/opt/rustdesk/
User=rustdesk
Group=rustdesk
Restart=always
StandardOutput=append:/var/log/rustdesk/relayserver.log
StandardError=append:/var/log/rustdesk/relayserver.error
# Restart service after 10 seconds if node service crashes
RestartSec=10

[Install]
WantedBy=multi-user.target

EOF
## End service file

## Enable services
systemctl enable rustdesksignal.service
systemctl start rustdesksignal.service
systemctl enable rustdeskrelay.service
systemctl start rustdeskrelay.service

## Get key
## you want to change the key, remove the id_ed25519 and id_ed25519.pub files and restart hbbs/hbbr, hbbs will generate a new key pair.
cat /opt/rustdesk/id_ed25519.pub
