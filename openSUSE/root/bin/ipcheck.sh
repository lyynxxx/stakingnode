#!/bin/bash
MYIP=$(curl ifconfig.me)
CONFIP=$(grep "external_address" /opt/cro-sentry/.chain-maind/config/config.toml | cut -d " " -f3 | sed 's/"//g'| cut -d":" -f1)
if [ "${MYIP}" == "${CONFIP}" ]; then
	echo "Nothing to do. External IP and configured IP are the same."
else
	echo "Externap IP update is required. Changing config and initiating restart..."
	sed -i.bak -E "s/^external_addre.*/external_address\ =\ \"${MYIP}:26656\"/g" /opt/cro-sentry/.chain-maind/config/config.toml
	chown sentry /opt/cro-sentry/.chain-maind/config/config.toml
	systemctl restart cronode
fi
