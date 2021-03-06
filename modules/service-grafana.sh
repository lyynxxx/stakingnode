#!/bin/bash
## Add service user for grafana
groupadd grafana
useradd --system -g grafana --no-create-home --shell /bin/false grafana
mkdir /etc/grafana
mkdir -p /opt/grafana
cd /opt/grafana
curl -LOJk https://dl.grafana.com/oss/release/grafana-8.3.3.linux-amd64.tar.gz
tar -xf grafana-8.3.3.linux-amd64.tar.gz
rm grafana-8.3.3.linux-amd64.tar.gz
mv grafana-8.3.3/* .
rm -rf grafana-8.3.3
chown -R grafana:grafana /opt/grafana

mv /tmp/kickstart/stakingnode/os/openSUSE/etc/systemd/system/grafana.service /etc/systemd/system/
chown root:root /etc/systemd/system/grafana.service
chmod 644 /etc/systemd/system/grafana.service

systemctl deamon-reload
systemctl enable grafana
