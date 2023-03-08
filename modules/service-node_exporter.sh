#!/bin/bash

## Create user and folders for node_exporter
## Textfile Exporter home: /opt/node_exporter
groupadd node_exporter
useradd --system -g node_exporter --no-create-home --shell /bin/false node_exporter
mkdir /etc/node_exporter
mkdir /opt/node_exporter

## Download node_exporter (amd64)
cd /opt/tmp
curl -LOk https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
tar -xf node_exporter-1.5.0.linux-amd64.tar.gz
cp node_exporter-1.5.0.linux-amd64/node_exporter /usr/local/bin/

## Fix permissions
chown -R node_exporter:node_exporter /etc/node_exporter
chown -R node_exporter:node_exporter /opt/node_exporter
chown node_exporter:node_exporter /usr/local/bin/node_exporter

## Cleanup
rm -rf /opt/tmp/node_exporter*

## Copy/enable systemd service
cp /tmp/kickstart/stakingnode/os/openSUSE/etc/systemd/system/node_exporter.service /etc/systemd/system/
chown root:root /etc/systemd/system/node_exporter.service
chmod 644 /etc/systemd/system/node_exporter.service

systemctl enable node_exporter

## FW (optional source filter)
# nft add rule inet my_table tcp_chain ip saddr 130.61.16.13 tcp dport 9100 counter accept
# nft list ruleset > /etc/sysconfig/nftables.conf