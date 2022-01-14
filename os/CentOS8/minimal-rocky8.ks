#inst.ks=http://192.168.10.125/vm/minimal.ks ip=ip::gateway:netmask:hostname:interface(enp0s3):none nameserver=x.x.x.x
#version=RHEL8/CentOS 8/Rocky Linux 8

## Use text mode install
text
## Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
## System language
lang en_US.UTF-8
## Reboot the machine after the installation finished
reboot


## Network information, use the first, plugged in NIC, so don't have to know the device name
## use --device=ens3 or --device=eth0 if you know the device name
## Kickstart install a hosted machine requires netwotking before you can download the KS file :) 
## add the following boot parameters: ip=ip::gateway:netmask:hostname:interface:none also nameserver=.... is needed
network  --bootproto=static --device=link --gateway=192.168.10.1 --ip=192.168.10.92 --nameserver=8.8.8.8 --netmask=255.255.255.0 --noipv6 --activate
network  --hostname=mail.vm


## Use network installation, mirror definintion
url --url http://mirror.niif.hu/rockylinux/8.5/BaseOS/x86_64/os/ --noverifyssl


## Root password
rootpw --plaintext JaffaKree123!%/
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
part /boot --fstype="xfs" --size=256 --fsoptions="rw,nodev,nosuid,noexec,noatime,seclabel,attr2,inode64,noquota"
part pv.01 --fstype="lvmpv" --size=1 --grow
volgroup cl pv.01
logvol / --fstype="xfs" --name=root --vgname=cl --size=2000 --fsoptions="rw,nosuid,nodev,seclabel,attr2,inode64,noquota"
logvol /tmp --fstype="xfs" --name=tmp --vgname=cl --size=1000 --fsoptions="rw,nodev,nosuid,noexec,noatime,seclabel,attr2,inode64,noquota"
logvol /var --fstype="xfs" --name=var --vgname=cl --size=2000 --fsoptions="rw,nodev,nosuid,noexec,seclabel,attr2,inode64,noquota"
logvol /usr --fstype="xfs" --name=usr --vgname=cl --size=3000 --fsoptions="rw,nodev,noatime,seclabel,attr2,inode64,noquota"
logvol swap --fstype="swap" --name=swap --vgname=cl --size=5000
logvol /opt --fstype="xfs" --name=opt --vgname=cl --percent=90 --grow --fsoptions="rw,nodev,nosuid,noatime,seclabel,attr2,inode64,noquota"

## Create non privileged users and service users
user --name=lyynxxx --groups=wheel --password=password --plaintext

%packages
@^minimal-environment
policycoreutils-python-utils
tar
git
%end

%addon com_redhat_kdump --disable --reserve-mb='auto'
%end



%post --log=/root/ks_results.out

## sub manager required only, if you use RHEL
#subscription-manager register --auto-attach --username=lyx --password= 

## hardening logins
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


## add epel repo and fail2ban
yum install -y epel-release
yum install -y fail2ban htop
systemctl enable fail2ban

## add sshd port to SELinux config and open the new port in firewalld
semanage port -a -t ssh_port_t -p tcp 2992


## Fluff firewalld and use pure nftables
systemctl disable firewalld
systemctl mask --now firewalld
systemctl enable nftables


## Config the one technical user, who can log in, add ssh key
mkdir -p /home/lyynxxx/.ssh
chmod 750 /home/lyynxxx/.ssh
chown -R lyynxxx:lyynxxx /home/lyynxxx
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAsCaKUzXes0z4WMqY8tQ9PsTEFmYVIyj7nYd4F9iZXSHZfDv6AbyCudGVXHdrdAe4VnMmoWVg6j8k546KQzFZ3bQl5UJdWrqulwCvFrH8yEyouqmA6OeSSAz7ALG85FBYiVWVKWrlzLqAIT/Gn+Ud57Pu3d4OowH00EXqksKdeux/eT+nyGuC7Je2ecvXLqETOhOJDhAicZf8SEcu5Rsbz7dEqZPnXC+4zfibqDuldzKDEkYL4Pyc4mcG+F15yxmW0OyjMLUI93kcgtmwXVKRPV2k0ceuqa7a3zlhbwae/ofgC7AwsUBZYdxxSfxmkGIXZYfoaN1PxiXj+aiMFdis5w== tech-nopriv" > /home/lyynxxx/.ssh/authorized_keys
chown lyynxxx:lyynxxx /home/lyynxxx/.ssh/authorized_keys
chmod 400 /home/lyynxxx/.ssh/authorized_keys

mkdir /opt/tmp
chown -R lyynxxx /opt/tmp
chmod 700 /opt/tmp #if I need to copy something here... or more space then in my home
chown -R lyynxxx:lyynxxx /home/lyynxxx


## MAGIC!
mkdir -p /tmp/kickstart
cd /tmp/kickstart

git clone https://gitlab.com/lyynxxx/stakingnode.git

## Auditd
mv /tmp/kickstart/stakingnode/os/openSUSE/etc/audit/rules.d/audit.rules /etc/audit/rules.d/audit.rules
chown root:root /etc/audit/rules.d/audit.rules
chmod 600 /etc/audit/rules.d/audit.rules

## Fail2ban & nftables
mv /tmp/kickstart/stakingnode/os/openSUSE/etc/fail2ban/action.d/nftables-common.local /etc/fail2ban/action.d/nftables-common.local
chown root:root /etc/fail2ban/action.d/nftables-common.local
chmod 644 /etc/fail2ban/action.d/nftables-common.local

mv /tmp/kickstart/stakingnode/os/openSUSE/etc/fail2ban/jail.local /etc/fail2ban/jail.local
chown root:root /etc/fail2ban/jail.local
chmod 644 /etc/fail2ban/jail.local

## nftables config
mv /tmp/kickstart/stakingnode/os/openSUSE/etc/sysconfig/nftables.conf /etc/sysconfig/nftables.conf
chown root:root /etc/sysconfig/nftables.conf
chmod 600 /etc/sysconfig/nftables.conf

## Sysctl tuning
cat /tmp/kickstart/stakingnode/os/openSUSE/etc/sysctl.d/99-sysctl.conf > /etc/sysctl.d/99-sysctl.conf
mv /tmp/kickstart/stakingnode/os/openSUSE/etc/systemd/system/nftables.service /etc/systemd/system/

## SSH
cat /tmp/kickstart/stakingnode/os/openSUSE/etc/ssh/sshd_config > /etc/ssh/sshd_config
chown root:root /etc/ssh/sshd_config
chmod 640 /etc/ssh/sshd_config

# Don't forget to set your own key!!
mv /tmp/kickstart/stakingnode/openSUSE/root/.mailrc /root/.mailrc
chown root:root /root/.mailrc
chmod 644 /root/.mailrc

# cleanup
#rm -rf /tmp/kickstart

systemctl daemon-reload

## MAGIC ENDS...


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
