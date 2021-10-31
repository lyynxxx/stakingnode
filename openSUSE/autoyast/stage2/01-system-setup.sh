#!/bin/bash
# ifcfg=*="IPS_NETMASK,GATEWAYS,NAMESERVERS,DOMAINS"
## logins
sed -i 's/^.*LOG_OK_LOGINS.*/LOG_OK_LOGINS yes/' /etc/login.defs
sed -i 's/^UMASK.*/UMASK 077/' /etc/login.defs


## securing the console
echo "console" > /etc/securetty
systemctl mask debug-shell.service
systemctl stop debug-shell.service
systemctl daemon-reload


## securing cron and at, only root will have access
systemctl mask ctrl-alt-del.target
rm /etc/cron.deny 2> /dev/null
rm /etc/at.deny 2> /dev/null
echo 'root' > /etc/cron.allow
echo 'root' > /etc/at.allow
chown root:root /etc/cron*
chmod og-rwx /etc/cron*
chown root:root /etc/at*
chmod og-rwx /etc/at*

## Localtime
ln -sf /usr/share/zoneinfo/Europe/Budapest /etc/localtime

mkdir -p /tmp/kickstart
cd /tmp/kickstart
#git config --global http.sslVerify false
git clone https://gitlab.com/lyynxxx/stakingnode.git

## Auditd
mv /tmp/kickstart/stakingnode/openSUSE/etc/audit/rules.d/audit.rules /etc/audit/rules.d/audit.rules
chown root:root /etc/audit/rules.d/audit.rules
chmod 600 /etc/audit/rules.d/audit.rules

## Fail2ban & nftables
mv /tmp/kickstart/stakingnode/openSUSE/etc/fail2ban/action.d/nftables-common.local /etc/fail2ban/action.d/nftables-common.local
chown root:root /etc/fail2ban/action.d/nftables-common.local
chmod 644 /etc/fail2ban/action.d/nftables-common.local

mv /tmp/kickstart/stakingnode/openSUSE/etc/fail2ban/jail.local /etc/fail2ban/jail.local
chown root:root /etc/fail2ban/jail.local
chmod 644 /etc/fail2ban/jail.local

## nftables config
mv /tmp/kickstart/stakingnode/openSUSE/etc/sysconfig/nftables.conf /etc/sysconfig/nftables.conf
chown root:root /etc/sysconfig/nftables.conf
chmod 600 /etc/sysconfig/nftables.conf

## Sysctl tuning
cat /tmp/kickstart/stakingnode/openSUSE/etc/sysctl.d/99-sysctl.conf > /etc/sysctl.d/99-sysctl.conf
mv /tmp/kickstart/stakingnode/openSUSE/etc/systemd/system/nftables.service /etc/systemd/system/

## SSH
cat /tmp/kickstart/stakingnode/openSUSE/etc/ssh/sshd_config > /etc/ssh/sshd_config
chown root:root /etc/ssh/sshd_config
chmod 640 /etc/ssh/sshd_config

# Don't forget to set your own key!!
mv /tmp/kickstart/stakingnode/openSUSE/root/.mailrc /root/.mailrc
chown root:root /root/.mailrc
chmod 640 /root/.mailrc

# Daily Aureport logs
mkdir -p /root/bin
mv /tmp/kickstart/stakingnode/openSUSE/root/bin/reports.sh /root/bin/aureport_daily.sh
chown root:root /root/bin/aureport_daily.sh
chmod 640 /root/bin/aureport_daily.sh


systemctl daemon-reload
systemctl enable fail2ban
systemctl enable auditd
systemctl enable nftables



## sudo by default ask the root pwd, dont't do that..
#sed -i "s/^Defaults\ targetpw.*/#/g" /etc/sudoers
#sed -i "s/^ALL\ targetpw.*/#/g" /etc/sudoers
#echo "lyynxxx ALL=(ALL) ALL" >> /etc/sudoers
#echo "" >> /etc/sudoers

## fix home permissions, fluff other users
groupadd lyynxxx
usermod -G lyynxxx -g lyynxxx lyynxxx
chmod 750 /home/lyynxxx

## temp folder/for backups
mkdir /opt/tmp
chown lyynxxx /opt/tmp


## fine tune fstab
# Hide processes from users. Users can see only their own process list
echo "proc                    /proc                   proc    defaults,hidepid=2    0 0" >> /etc/fstab

# set /usr to read-only
LINE=$(grep -n '/usr' /etc/fstab| cut -d ":" -f 1)
if [ ! -z "$LINE" ]; then 
	sed -i "${LINE}s/rw/ro/" /etc/fstab
fi
unset LINE

# set /boot to read-only
LINE=$(grep -n '/boot ' /etc/fstab| cut -d ":" -f 1)
if [ ! -z "$LINE" ]; then 
sed -i "${LINE}s/rw/ro/" /etc/fstab
fi
unset LINE

# set /boot to read-only
LINE=$(grep -n '/boot/' /etc/fstab| cut -d ":" -f 1)
if [ ! -z "$LINE" ]; then 
	sed -i "${LINE}s/rw/ro/" /etc/fstab
fi
unset LINE
# set / to noexec
#LINE=$(grep -n '/ ' /etc/fstab| cut -d ":" -f 1)
#sed -i "${LINE}s/nodev/noexec,nodev/" /etc/fstab

# Prevent chain-maind spamfork dbus sessions, no need anyway
#chmod o-x /usr/bin/dbus-launch

#TODO: https://gist.github.com/ageis/f5595e59b1cddb1513d1b425a323db04
###### systemd-analyze security name_of_service.service
