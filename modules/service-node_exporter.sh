## Add service user - node_exporter for Prometheus
groupadd node_exporter
useradd --system -g node_exporter --no-create-home --shell /bin/false node_exporter
cd /opt/tmp
curl -LOk https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
tar -xf node_exporter-1.0.1.linux-amd64.tar.gz
cp /opt/tmp/node_exporter-1.0.1.linux-amd64/node_exporter /usr/local/bin/
chown node_exporter:node_exporter /usr/local/bin/node_exporter
mkdir -p /opt/node_exporter/textfile_collector/
chown node_exporter:node_exporter /opt/node_exporter/textfile_collector/
rm -rf node_exporter-1.0.1.linux-amd64.tar.gz

mv /tmp/kickstart/eth2nodes/opensuse/etc/systemd/system/node_exporter.service /etc/systemd/system/node_exporter.service
chown root:root /etc/systemd/system/node_exporter.service
chmod 644 /etc/systemd/system/node_exporter.service

systemctl daemon-reload
systemctl enable node_exporter
