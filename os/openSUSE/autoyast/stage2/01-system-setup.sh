#!/bin/bash
# ifcfg=*="IPS_NETMASK,GATEWAYS,NAMESERVERS,DOMAINS"

## logins, set your paranoid levels, but installer scripts that create/copy files may or may not work as they should with 077 umask...
sed -i 's/^.*LOG_OK_LOGINS.*/LOG_OK_LOGINS yes/' /etc/login.defs
sed -i 's/^UMASK.*/UMASK 077/' /etc/login.defs
#sed -i 's/^UMASK.*/UMASK 027/' /etc/login.defs


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

cd /tmp
git clone https://github.com/lyynxxx/stakingnode.git

## Auditd
mv /tmp/stakingnode/os/common/etc/audit/rules.d/audit-hc.rules /etc/audit/rules.d/audit.rules
chown root:root /etc/audit/rules.d/audit.rules
chmod 600 /etc/audit/rules.d/audit.rules

## nftables config, change NIC definition to the active NIC... first match!
mv /tmp/stakingnode/os/common/nftables/nftables.conf /etc/sysconfig/nftables.conf
chown root:root /etc/sysconfig/nftables.conf
chmod 600 /etc/sysconfig/nftables.conf
NICNAME=$(ip addr show | awk '/inet.*brd/{print $NF; exit}')
sed -i "s/^define\ host_nic.*/define\ host_nic=\"$NICNAME\"/g" /etc/sysconfig/nftables.conf
mv /tmp/stakingnode/os/openSUSE/etc/systemd/system/nftables.service /etc/systemd/system/
chown root:root /etc/systemd/system/nftables.service
chmod 600 /etc/systemd/system/nftables.service

## Sysctl tuning
mv /tmp/stakingnode/os/common/etc/sysctl.d/99-sysctl.conf /etc/sysctl.conf

## SSH
mv /tmp/stakingnode/os/common/etc/ssh/sshd_config /etc/ssh/sshd_config
chown root:root /etc/ssh/sshd_config
chmod 600 /etc/ssh/sshd_config

## Fail2ban default ssh
mv /tmp/stakingnode/os/common/etc/fail2ban/jail.local /etc/fail2ban/jail.local
chown root:root /etc/fail2ban/jail.local
chmod 644 /etc/fail2ban/jail.local

## Enable fail2ban, auditd and firewall on the new system
systemctl daemon-reload
systemctl enable fail2ban
systemctl enable auditd
systemctl enable nftables

## disabling kernel modules for filesystems and networks
rm -rf /etc/modprobe.d/firewalld*
cp /tmp/stakingnode/os/common/etc/modprobe.d/disable-fs.conf /etc/modprobe.d/
cp /tmp/stakingnode/os/common/etc/modprobe.d/disable-network.conf /etc/modprobe.d/

## Fluff firewalld, it's only a frontend. I have nftables!
systemctl disable firewalld
systemctl mask --now firewalld

## update crypto policies, disable weak system-wide poilicies
## alternative: update-crypto-policies --set FUTURE
cp /tmp/stakingnode/os/common/etc/crypto-policies/policies/modules/* /etc/crypto-policies/policies/modules/
update-crypto-policies --set DEFAULT:NO-SHA1:NO-WEAKMAC:NO-SSHCBC:NO-SSHCHACHA20:NO-SSHETM

## hide some stuff
echo "export HISTCONTROL=ignorespace" >> /root/.bash_profile

## Zypper repo cleanup
rm -rf /etc/zypp/repos.d/*.repo
mv /tmp/stakingnode/os/openSUSE/etc/zypp/repos.d/openSUSE-Leap-main.repo /etc/zypp/repos.d/
mv /tmp/stakingnode/os/openSUSE/etc/zypp/repos.d/openSUSE-Leap-nonoss.repo /etc/zypp/repos.d/
mv /tmp/stakingnode/os/openSUSE/etc/zypp/repos.d/openSUSE-Leap-updates.repo /etc/zypp/repos.d/
mv /tmp/stakingnode/os/openSUSE/etc/zypp/repos.d/openSUSE-Leap-updates-nonoss.repo /etc/zypp/repos.d/
mv /tmp/stakingnode/os/openSUSE/etc/zypp/repos.d/openSUSE-Leap-updates-backports.repo /etc/zypp/repos.d/
mv /tmp/stakingnode/os/openSUSE/etc/zypp/repos.d/openSUSE-Leap-updates-sle.repo /etc/zypp/repos.d/

chown root:root /etc/zypp/repos.d/*.repo
chmod 600 /etc/zypp/repos.d/*.repo
# Delete 0 size files (old repo, used by autoyast installer)
find /etc/zypp/repos.d/ -type f -size 0 -delete

## fix home permissions, don't allow the "users" group to see my home dir content
groupadd lyynxxx
usermod -G lyynxxx -g lyynxxx lyynxxx
chmod 750 /home/lyynxxx

## temp folder/for backups
mkdir /opt/tmp
chown lyynxxx /opt/tmp

## Change Zypp config, don't install all the recommended sht...
sed -i 's/.*solver.onlyRequires.*/solver.onlyRequires=true/' /etc/zypp/zypp.conf

## Configure /dev/shm
echo "tmpfs /dev/shm tmpfs defaults,rw,nosuid,nodev,noexec,relatime 0 0" >> /etc/fstab

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

## fine tune fstab
# Hide processes from users. Users can see only their own process list
#echo "proc                    /proc                   proc    defaults,hidepid=2    0 0" >> /etc/fstab


#TODO: https://gist.github.com/ageis/f5595e59b1cddb1513d1b425a323db04
###### systemd-analyze security name_of_service.service
