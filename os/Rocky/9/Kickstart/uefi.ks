# Rocky Linux 9 Kickstart Template - UEFI and GPT

# System authorization information
auth --enableshadow --passalgo=sha512

# Network information
network --bootproto=dhcp --device=eth0 --activate

# Use graphical installation
graphical

# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'

# System language
lang en_US.UTF-8

# Installation source
url --url="http://mirror.centos.org/rocky/9/BaseOS/x86_64/os/"

# Minimal installation with additional packages
%packages --nobase
@^minimal-environment
mc
jq
%end

# System timezone
timezone Europe/Budapest --isUtc --ntpservers=0.hu.pool.ntp.org,1.hu.pool.ntp.org,2.hu.pool.ntp.org

# Root password
rootpw --iscrypted $6$randomsalt$randomhashedpassword

# Bootloader configuration for UEFI
bootloader --location=/boot --boot-drive=sda --append="rhgb quiet"

# Partition clearing information
clearpart --all --initlabel --disklabel=gpt
zerombr

# Disk partitioning information
part /boot/efi --fstype="efi" --ondisk=sda --size=600 --fsoptions="umask=0077,shortname=winnt"
part /boot --fstype="xfs" --ondisk=sda --size=1024
part pv.01 --fstype="lvmpv" --ondisk=sda --size=8192 --grow
volgroup vgroot pv.01

logvol /       --fstype="xfs" --size=8192 --name=root --vgname=vgroot --grow
logvol swap    --fstype="swap" --size=2048 --name=swap --vgname=vgroot
logvol /usr    --fstype="xfs" --size=4096 --name=usr --vgname=vgroot
logvol /var    --fstype="xfs" --size=4096 --name=var --vgname=vgroot
logvol /var/tmp --fstype="xfs" --size=2048 --name=var_tmp --vgname=vgroot
logvol /var/log --fstype="xfs" --size=2048 --name=var_log --vgname=vgroot

# Mount /tmp as tmpfs
%post
echo "tmpfs /tmp tmpfs defaults,nodev,nosuid,noexec,mode=1777 0 0" >> /etc/fstab

# Hardened fstab flags for /var/tmp and /var/log
sed -i '/\/var\/tmp/s/defaults/defaults,nodev,nosuid,noexec/' /etc/fstab
sed -i '/\/var\/log/s/defaults/defaults,nodev/' /etc/fstab
%end

# System boot settings
firstboot --disable
skipx

# Enable and start SSH service
services --enabled=sshd

# Reboot after installation
reboot

# User creation (example user, you can remove or edit this)
user --name=testuser --password=$6$randomsalt$randomhashedpassword --iscrypted --gecos="Test User"
