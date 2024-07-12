#!/usr/bin/env bash
## If any of these services are not required, it is recommended that the package be removed. (Rocky 9, service names may differ on other distros)
## the package is required for a dependency:
## systemctl stop <service_name>.socket <service_name>.service
## systemctl mask <service_name>.socket <service_name>.service

systemctl is-enabled autofs.service 2>/dev/null | grep 'enabled'
systemctl is-enabled avahi-daemon.socket avahi-daemon.service 2>/dev/null | grep 'enabled'
systemctl is-enabled dhcpd.service dhcpd6.service 2>/dev/null | grep 'enabled'
systemctl is-enabled named.service 2>/dev/null | grep 'enabled'
systemctl is-enabled dnsmasq.service 2>/dev/null | grep 'enabled'
systemctl is-enabled smb.service 2>/dev/null | grep '^active'
systemctl is-enabled vsftpd.service 2>/dev/null | grep 'enabled'
systemctl is-enabled dovecot.socket dovecot.service cyrus-imapd.service 2>/dev/null | grep 'enabled'
systemctl is-enabled nfs-server.service 2>/dev/null | grep 'enabled'
systemctl is-enabled ypserv.service 2>/dev/null | grep 'enabled'
systemctl is-enabled cups.socket cups.service 2>/dev/null | grep 'enabled'
systemctl is-enabled rpcbind.socket rpcbind.service 2>/dev/null | grep 'enabled'
systemctl is-enabled rsyncd.socket rsyncd.service 2>/dev/null | grep 'enabled'
systemctl is-enabled snmpd.service 2>/dev/null | grep 'enabled'
systemctl is-enabled telnet.socket 2>/dev/null | grep 'enabled'
systemctl is-enabled tftp.socket tftp.service 2>/dev/null | grep 'enabled'
systemctl is-active squid.service 2>/dev/null | grep '^active'
systemctl is-enabled httpd.socket httpd.service nginx.service 2>/dev/null | grep 'enabled'
systemctl is-enabled xinetd.service 2>/dev/null | grep 'enabled'
rpm -q xorg-x11-server-common


## Services listening on the system pose a potential risk as an attack vector. 
## These services should be reviewed, and if not required, the service should be stopped, and the package containing the service should be removed.
## If required packages have a dependency, the service should be stopped and masked to reduce the attack surface of the system.
