#inst.ks=http://192.168.10.125/vm/minimal.ks ip=ip::gateway:netmask:hostname:interface(enp0s3 or ens3):none nameserver=x.x.x.x
#version=RHEL8

## Use text mode install
text

## Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'

## System language

lang en_US.UTF-8
## Reboot the machine after the installation finished
reboot

## Install from ISO
cdrom

## Network information, use the first, plugged in NIC, so don't have to know the device name
## use --device=ens3 or --device=eth0 if you know the device name
## Kickstart install a hosted machine requires netwotking before you can download the KS file :) 
## add the following boot parameters: ip=ip::gateway:netmask:hostname:interface:none also nameserver=.... is needed
network  --bootproto=static --device=link --gateway=192.168.0.1 --ip=192.168.0.55 --nameserver=192.168.0.1 --netmask=255.255.255.0 --noipv6 --activate
network  --hostname=host.test

## Root password
## Change this at first login!!!!!
rootpw --plaintext Admin123456 

## Don't run the Setup Agent on first boot
firstboot --disabled

## Do not configure the X Window System
skipx

## System services
services --enabled="chronyd"

## System timezone
## 0.<countrycode>.pool.nto.org usually works, but check/use your own
timezone Europe/Budapest --isUtc --ntpservers=0.hu.pool.ntp.org,1.hu.pool.ntp.org,2.hu.pool.ntp.org

## Clearing partition information, delete all partition on all disk!
clearpart --all --initlabel

## Disk partitioning information
part /boot/efi --fstype="vfat" --size=1024  #uncomment for UEFI install
part /boot --fstype="xfs" --size=384 --fsoptions="rw,nodev,nosuid,noexec,noatime,seclabel,attr2,inode64,noquota"
part pv.01 --fstype="lvmpv" --size=1 --grow
volgroup cl pv.01
logvol / --fstype="xfs" --name=root --vgname=cl --size=2000 --fsoptions="rw,nosuid,nodev,seclabel,attr2,inode64,noquota"
logvol /tmp --fstype="xfs" --name=tmp --vgname=cl --size=1000 --fsoptions="rw,nodev,nosuid,noexec,noatime,seclabel,attr2,inode64,noquota"
logvol /usr --fstype="xfs" --name=usr --vgname=cl --size=3000 --fsoptions="rw,nodev,noatime,seclabel,attr2,inode64,noquota"
logvol swap --fstype="swap" --name=swap --vgname=cl --size=5000
logvol /var--fstype="xfs" --name=opt --vgname=cl --size=4000 --fsoptions="rw,nodev,nosuid,noatime,seclabel,attr2,inode64,noquota"
logvol /opt --fstype="xfs" --name=var --vgname=cl --percent=90 --grow --fsoptions="rw,nodev,nosuid,noexec,seclabel,attr2,inode64,noquota"

## Create non privileged users and service users
user --name=lyynxxx --groups=wheel --password=PASSWORD --plaintext

%packages
@^minimal-environment
policycoreutils-python-utils
tar
git
mc
%end

%addon com_redhat_kdump --disable --reserve-mb='auto'
%end



%post --log=/root/ks_results.out

## Register the systam and add extre repos
subscription-manager register --auto-attach --username=RHELPORTALUSER --password=RHELPORTLPWD
subscription-manager repos --enable codeready-builder-for-rhel-8-x86_64-rpms
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

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


## Fail2ban install
dnf install -y fail2ban htop
systemctl enable fail2ban

## add sshd port to SELinux config and open the new port in firewalld
semanage port -a -t ssh_port_t -p tcp 2992

## Fluff firewalld
systemctl disable firewalld
systemctl mask --now firewalld


## Localtime
ln -sf /usr/share/zoneinfo/Europe/Budapest /etc/localtime

mkdir -p /tmp/kickstart
cd /tmp/kickstart
#git config --global http.sslVerify false
git clone https://gitlab.com/lyynxxx/stakingnode.git

## Auditd
mv /tmp/kickstart/stakingnode/os/RedHat8/etc/audit/rules.d/audit.rules /etc/audit/rules.d/audit.rules
chown root:root /etc/audit/rules.d/audit.rules
chmod 600 /etc/audit/rules.d/audit.rules

## nftables config
mv /tmp/kickstart/stakingnode/os/RedHat8/etc/sysconfig/nftables.conf /etc/sysconfig/nftables.conf
chown root:root /etc/sysconfig/nftables.conf
chmod 600 /etc/sysconfig/nftables.conf

## Sysctl tuning
cat /tmp/kickstart/stakingnode/os/RedHat8/etc/sysctl.d/99-sysctl.conf > /etc/sysctl.d/99-sysctl.conf
mv /tmp/kickstart/stakingnode/os/RedHat8/etc/systemd/system/nftables.service /etc/systemd/system/

## SSH
cat /tmp/kickstart/stakingnode/os/RedHat8/etc/ssh/sshd_config > /etc/ssh/sshd_config
chown root:root /etc/ssh/sshd_config
chmod 640 /etc/ssh/sshd_config

## Fail2ban default ssh
mv /tmp/kickstart/stakingnode/os/openSUSE/etc/fail2ban/jail.local /etc/fail2ban/jail.local
chown root:root /etc/fail2ban/jail.local
chmod 644 /etc/fail2ban/jail.local

# Enable fail2ban, auditd and firewall on the new system
systemctl daemon-reload
systemctl enable fail2ban
systemctl enable auditd
systemctl enable nftables

## temp folder/for backups
mkdir /opt/tmp
chown lyynxxx /opt/tmp

## hide some stuff
echo "export HISTCONTROL=ignorespace" >> /root/.bash_profile


## Config the one technical user, who can log in, add ssh key
mkdir -p /home/lyynxxx/.ssh
chmod 750 /home/lyynxxx/.ssh
chown -R lyynxxx:lyynxxx /home/lyynxxx
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAsCaKUzXes0z4WMqY8tQ9PsTEFmYVIyj7nYd4F9iZXSHZfDv6AbyCudGVXHdrdAe4VnMmoWVg6j8k546KQzFZ3bQl5UJdWrqulwCvFrH8yEyouqmA6OeSSAz7ALG85FBYiVWVKWrlzLqAIT/Gn+Ud57Pu3d4OowH00EXqksKdeux/eT+nyGuC7Je2ecvXLqETOhOJDhAicZf8SEcu5Rsbz7dEqZPnXC+4zfibqDuldzKDEkYL4Pyc4mcG+F15yxmW0OyjMLUI93kcgtmwXVKRPV2k0ceuqa7a3zlhbwae/ofgC7AwsUBZYdxxSfxmkGIXZYfoaN1PxiXj+aiMFdis5w== tech-nopriv" > /home/lyynxxx/.ssh/authorized_keys
chown lyynxxx:lyynxxx /home/lyynxxx/.ssh/authorized_keys
chmod 400 /home/lyynxxx/.ssh/authorized_keys

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
LINE=$(grep -n '/ ' /etc/fstab| cut -d ":" -f 1)
if [ ! -z "$LINE" ]; then 
	sed -i "${LINE}s/nodev/noexec,nodev/" /etc/fstab
fi


# Set immutable options for password files, to prevent modification or accidental deletion (this will fluff you too! :D )
chattr +i /etc/passwd
chattr +i /etc/shadow

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end
