#!/bin/bash

## Add service users - mev
groupadd mev
useradd --system -g mev --no-create-home --shell /bin/false mev
mkdir -p /opt/mev/bin

zypper in go1.12

mkdir -p /opt/tmp/mev-build
cd /opt/tmp/mev-build
CGO_CFLAGS="-O -D__BLST_PORTABLE__" go install github.com/flashbots/mev-boost@latest

cp $HOME/go/bin/mev-boost /opt/mev/bin
chown -R mev:mev /opt/mev/
