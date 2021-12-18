#!/bin/bash

## Add service users - Taraxa
groupadd taraxa
useradd --system -g taraxa -d /opt/taraxa --shell /bin/false taraxa
mkdir -p /opt/taraxa/bin
mkdir -p /opt/taraxa/data
mkdir -p /opt/taraxa/.conf
chown -R taraxa:taraxa /opt/taraxa

mv /tmp/kickstart/stakingnode/openSUSE/etc/systemd/system/taraxa.service /etc/systemd/system/
chown root:root /etc/systemd/system/taraxa.service
chmod 644 /etc/systemd/system/taraxa.service

## The binary is not ready at this time, so the service is not enabled by default.
## I will compile the binary instead of using the docker images.

## Copy the compiled binary to /opt/taraxa/bin and enable the service
## systemctl enable taraxa

#TODO:
# Prepare config and download the node config/wallet json.