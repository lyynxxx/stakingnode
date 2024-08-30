# Rocky Linux 9 Kickstart - UEFI | Following the CIS recommendations with with additional fine-tuning.
# https://www.cisecurity.org/cis-benchmarks
###################################################################################################
# inst.ks=http://192.168.10.125/vm/minimal.ks ip=ip::gateway:netmask:hostname:interface(enp0s3):off nameserver=x.x.x.x



# System authorization information
auth --enableshadow --passalgo=sha512

# Network information
network --bootproto=dhcp --device=eth0 --activate
#network  --bootproto=static --device=link --gateway=192.168.50.1 --ip=192.168.50.92 --nameserver=192.168.50.1 --netmask=255.255.255.0 --noipv6 --activate
network  --hostname=rocky9.vm

# Use graphical installation
text

# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'

# System language
lang en_US.UTF-8

# Installation source (url: netinstall, network reuired; cdrom:iso file)
#cdrom
url --url="http://dl.rockylinux.org/pub/rocky/9/BaseOS/x86_64/os/"

# Minimal installation with additional packages (blocking packages from CIS recommendations, they can be installed later if needed)
%packages
@^minimal-environment
aide
audit
libselinux
nftables
rsyslog
sudo
policycoreutils-python-utils
git
mc
-avahi
-bind
-cups
-cyrus-imapd
-dhcp-server
-dnsmasq
-dovecot
-firewalld
-ftp
-gdm
-httpd
-mcstrans
-net-snmp
-nginx
-openldap-clients
-rsync-daemon
-samba
-setroubleshoot
-squid
-telnet
-telnet-server
-tftp
-tftp-server
-vsftpd
-xorg-x11-server-common

%end

# System timezone
timezone Europe/Budapest --utc 
timesource --ntp-server=0.hu.pool.ntp.org
timesource --ntp-server=1.hu.pool.ntp.org
timesource --ntp-server=2.hu.pool.ntp.org

# Root password, changit!!!
rootpw --plaintext changeit

# Partition clearing information; protect other disks if present: --only-use=vda !
ignoredisk --only-use=vda
clearpart --all --initlabel --disklabel=gpt
zerombr

# Disk partitioning information
part /boot/efi --fstype="efi" --ondisk=vda --size=600 --fsoptions="umask=0077,shortname=winnt"
part /boot --fstype="xfs" --ondisk=vda --size=512 --fsoptions="rw,nodev,nosuid,noexec,noatime,seclabel,inode64,noquota"
part pv.01 --fstype="lvmpv" --ondisk=vda --size=8192 --grow
volgroup vg00 pv.01

logvol /       --fstype="xfs" --size=5120 --name=root --vgname=vg00 --fsoptions="rw,nosuid,nodev,seclabel,inode64,noquota"
logvol swap    --fstype="swap" --size=4096 --name=swap --vgname=vg00 
logvol /home    --fstype="xfs" --size=3072 --name=home --vgname=vg00 --fsoptions="rw,nodev,nosuid,noexec,noatime,seclabel,inode64,noquota"
logvol /usr    --fstype="xfs" --size=3072 --name=usr --vgname=vg00 --fsoptions="rw,nodev,noatime,seclabel,inode64,noquota"
logvol /var    --fstype="xfs" --size=3072 --name=var --vgname=vg00 --fsoptions="rw,nodev,nosuid,noexec,noatime,seclabel,inode64,noquota"
logvol /var/tmp --fstype="xfs" --size=1024 --name=var_tmp --vgname=vg00 --fsoptions="rw,nodev,nosuid,noexec,noatime,seclabel,inode64,noquota"
logvol /var/log --fstype="xfs" --size=3072 --name=var_log --vgname=vg00 --fsoptions="rw,nodev,nosuid,noexec,noatime,seclabel,inode64,noquota"

%post
# /tmp as tmpfs in memory, will reset; securing shared memory for IPC
echo "tmpfs /tmp tmpfs defaults,nodev,nosuid,noexec,mode=1777,size=1G 0 0" >> /etc/fstab
echo "tmpfs /dev/shm tmpfs defaults,rw,nosuid,nodev,noexec,relatime 0 0" >> /etc/fstab

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

## Add epel repo
dnf install -y epel-release

## Fail2ban install, copy ready made config later
dnf install -y fail2ban htop
systemctl enable fail2ban

## add sshd port to SELinux config
semanage port -a -t ssh_port_t -p tcp 2992

## Localtime
ln -sf /usr/share/zoneinfo/Europe/Budapest /etc/localtime

## Download ready made configs and files
cd /tmp
git clone https://github.com/lyynxxx/stakingnode.git

## Auditd
mv /tmp/stakingnode/os/common/etc/audit/rules.d/audit-hc.rules /etc/audit/rules.d/audit.rules
chown root:root /etc/audit/rules.d/audit.rules
chmod 600 /etc/audit/rules.d/audit.rules

## nftables config
mv /tmp/stakingnode/os/common/nftables/nftables.conf /etc/sysconfig/nftables.conf
chown root:root /etc/sysconfig/nftables.conf
chmod 600 /etc/sysconfig/nftables.conf

## Sysctl tuning
mv /tmp/stakingnode/os/common/etc/sysctl.d/99-sysctl.conf /etc/sysctl.conf

## SSH
mv /tmp/stakingnode/os/common/etc/ssh/sshd_config /etc/ssh/sshd_config
chown root:root /etc/ssh/sshd_config
chmod 640 /etc/ssh/sshd_config

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

## Create default user with ssh key
useradd -m -s /bin/bash -d /home/lyynxxx lyynxxx
mkdir -p /home/lyynxxx/.ssh
chmod 750 /home/lyynxxx/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAsCaKUzXes0z4WMqY8tQ9PsTEFmYVIyj7nYd4F9iZXSHZfDv6AbyCudGVXHdrdAe4VnMmoWVg6j8k546KQzFZ3bQl5UJdWrqulwCvFrH8yEyouqmA6OeSSAz7ALG85FBYiVWVKWrlzLqAIT/Gn+Ud57Pu3d4OowH00EXqksKdeux/eT+nyGuC7Je2ecvXLqETOhOJDhAicZf8SEcu5Rsbz7dEqZPnXC+4zfibqDuldzKDEkYL4Pyc4mcG+F15yxmW0OyjMLUI93kcgtmwXVKRPV2k0ceuqa7a3zlhbwae/ofgC7AwsUBZYdxxSfxmkGIXZYfoaN1PxiXj+aiMFdis5w== tech-nopriv" > /home/lyynxxx/.ssh/authorized_keys
chown -R lyynxxx:lyynxxx /home/lyynxxx
chmod 400 /home/lyynxxx/.ssh/authorized_keys


## Set immutable options for password files, to prevent modification or accidental deletion (this will fluff you too! :D )
chattr +i /etc/passwd
chattr +i /etc/shadow


# set /usr to read-only
LINE=$(grep -n '/usr' /etc/fstab| cut -d ":" -f 1)
if [ ! -z "$LINE" ]; then 
	sed -i "${LINE}s/rw/ro/" /etc/fstab
fi
unset LINE


%end

# System boot settings
firstboot --disable
skipx

# Enable and start SSH and timesync service
services --enabled=sshd
services --enabled="chronyd"

# Reboot after installation
reboot
