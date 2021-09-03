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


## SSH
sed -i "s/^PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config
sed -i "s/^#Port.*/Port 2992/g" /etc/ssh/sshd_config
sed -i "s/^#StrictModes.*/StrictModes yes/g" /etc/ssh/sshd_config
sed -i "s/^#MaxAuthTries.*/MaxAuthTries 3/g" /etc/ssh/sshd_config
sed -i "s/^#HostbasedAuthentication.*/HostbasedAuthentication no/g" /etc/ssh/sshd_config
sed -i "s/^#IgnoreRhosts.*/IgnoreRhosts yes/g" /etc/ssh/sshd_config
sed -i "s/^#PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config
sed -i "s/^X11Forwarding.*/#X11Forwarding yes/g" /etc/ssh/sshd_config
sed -i "s/^#PubkeyAuthentication.*/PubkeyAuthentication yes/g" /etc/ssh/sshd_config
sed -i "/^#VersionAddendum.*/a AllowUsers=lyynxxx" /etc/ssh/sshd_config
sed -i "s/#ClientAliveInterval.*/ClientAliveInterval 120/g" /etc/ssh/sshd_config
sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config

## Fail2ban aggresive filtering
sed -i "s/^mode\ =.*/mode\ =\ agressive/g" /etc/fail2ban/filter.d/sshd.conf
sed -i "s/^#filter\ =.*/filter\ =\ sshd[mode=aggressive]/g" /etc/fail2ban/filter.d/sshd.conf

mkdir -p /tmp/kickstart
cd /tmp/kickstart
git clone https://gitlab.com/lyynxxx/eth2nodes.git
dos2unix /tmp/kickstart/*

## Auditd
mv /tmp/kickstart/eth2nodes/opensuse/etc/audit/rules.d/audit.rules /etc/audit/rules.d/audit.rules
chown root:root /etc/audit/rules.d/audit.rules
chmod 600 /etc/audit/rules.d/audit.rules

## Fail2ban & nftables
mv /tmp/kickstart/eth2nodes/opensuse/etc/fail2ban/action.d/nftables-common.local /etc/fail2ban/action.d/nftables-common.local
chown root:root /etc/fail2ban/action.d/nftables-common.local
chmod 644 /etc/fail2ban/action.d/nftables-common.local

mv /tmp/kickstart/eth2nodes/opensuse/etc/fail2ban/jail.local /etc/fail2ban/jail.local
chown root:root /etc/fail2ban/jail.local
chmod 644 /etc/fail2ban/jail.local

mv /tmp/kickstart/eth2nodes/opensuse/etc/nftables/fail2ban.conf /etc/nftables/fail2ban.conf
chown root:root /etc/nftables/fail2ban.conf
chmod 644 /etc/nftables/fail2ban.conf

## nftables config
mv /tmp/kickstart/eth2nodes/opensuse/etc/sysconfig/nftables-eth.conf /etc/sysconfig/nftables.conf
chown root:root /etc/sysconfig/nftables.conf
chmod 600 /etc/sysconfig/nftables.conf

## Sysctl tuning
cat /tmp/kickstart/eth2nodes/opensuse/etc/sysctl.d/99-sysctl.conf > /etc/sysctl.d/99-sysctl.conf
mv /tmp/kickstart/eth2nodes/opensuse/etc/systemd/system/nftables.service /etc/systemd/system/



# Don't forget to set your own key!!
mv /tmp/kickstart/eth2nodes/opensuse/root/.mailrc /root/.mailrc
chown root:root /root/.mailrc
chmod 640 /root/.mailrc

mv /tmp/kickstart/eth2nodes/opensuse/root/.profile-eth /root/.profile
chown root:root /root/.profile
chmod 640 /root/.profile

systemctl daemon-reload
systemctl enable fail2ban
systemctl enable auditd
systemctl enable nftables



## sudo by default ask the root pwd, dont't do that..
sed -i "s/^Defaults\ targetpw.*/#/g" /etc/sudoers
sed -i "s/^ALL\ targetpw.*/#/g" /etc/sudoers
echo "lyynxxx ALL=(ALL) ALL" >> /etc/sudoers
echo "" >> /etc/sudoers

## fix home permissions
groupadd lyynxxx
usermod -G lyynxxx -g lyynxxx lyynxxx
chmod 750 /home/lyynxxx

## temp folder/for backups
mkdir /opt/tmp
chown lyynxxx /opt/tmp


## fine tune fstab
# Hide processes from users. Users can see only their own process list
echo "proc                    /proc                   proc    defaults,hidepid=2    0 0" >> /etc/fstab

# set / to noexec
LINE=$(grep -n '/ ' /etc/fstab| cut -d ":" -f 1)
sed -i "${LINE}s/defaults/rw,nodev,nosuid,relatime,space_cache,subvol\=\/\@\/\.snapshots\/1\/snapshot/" /etc/fstab

# set /usr to read-only
LINE=$(grep -n '/usr' /etc/fstab| cut -d ":" -f 1)
sed -i "${LINE}s/subvol/ro,nodev,noatime,ssd,subvol/" /etc/fstab

# set /bin to read-only
LINE=$(grep -n '/bin' /etc/fstab| cut -d ":" -f 1)
sed -i "${LINE}s/subvol/ro,nodev,noatime,nodirtime,ssd,subvol/" /etc/fstab

# set /sbin to read-only
LINE=$(grep -n '/sbin' /etc/fstab| cut -d ":" -f 1)
sed -i "${LINE}s/subvol/ro,nodev,noatime,nodirtime,ssd,subvol/" /etc/fstab

# set /lib to read-only
LINE=$(grep -n '/lib' /etc/fstab| cut -d ":" -f 1)
sed -i "${LINE}s/subvol/ro,nodev,noatime,nodirtime,ssd,subvol/" /etc/fstab

# set /lib64 to read-only
LINE=$(grep -n '/lib64 ' /etc/fstab| cut -d ":" -f 1)
sed -i "${LINE}s/subvol/ro,nodev,noatime,nodirtime,ssd,subvol/" /etc/fstab

# set /tmp to nodev,nosuid,noexec,noatime
LINE=$(grep -n '/tmp' /etc/fstab| cut -d ":" -f 1)
sed -i "${LINE}s/subvol/rw,nodev,nosuid,noexec,noatime,nodirtime,ssd,subvol/" /etc/fstab

# set /var to nodev,nosuid,noexec,noatime
LINE=$(grep -n '/var' /etc/fstab| cut -d ":" -f 1)
sed -i "${LINE}s/subvol/rw,nodev,nosuid,noexec,noatime,nodirtime,ssd,subvol/" /etc/fstab

# set /boot to read-only
LINE=$(grep -n '/boot/grub2/x86_64-efi' /etc/fstab| cut -d ":" -f 1)
sed -i "${LINE}s/subvol/ro,nodev,nosuid,noexec,noatime,nodirtime,ssd,subvol/" /etc/fstab

# set /boot to read-only
LINE=$(grep -n '/boot/grub2/i386-pc' /etc/fstab| cut -d ":" -f 1)
sed -i "${LINE}s/subvol/ro,nodev,nosuid,noexec,noatime,nodirtime,ssd,subvol/" /etc/fstab

# set / to noexec
#LINE=$(grep -n '/ ' /etc/fstab| cut -d ":" -f 1)
#sed -i "${LINE}s/nodev/noexec,nodev/" /etc/fstab

# Prevent chain-maind spamfork dbus sessions, no need anyway
#chmod o-x /usr/bin/dbus-launch
