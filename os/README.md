As I see there isn't such thing as a security "silver bullet", what solves everything. I must assume, my system is not unbreakable, therefore I need to create a few security layer. None of the layers itself are enough, but together they can mitigate a lot of the attack vectors.

# Planing the partitions
Security begins even before I start the installation. During the installation process, I have an option to define the different partitions, filesystem types and sizes. I can apply different restrictions or fine tune the behavior of the filesystem. Separating the major system folders can help more then most people thinks.


| Partition | Size | What for |
| ------ | ------ | ------ |
| /boot | 250M | Isolated boot partition for the kernel and the boot config files. I will make this read-only and unlock it only I need to update the system. Also apply nodev,nosuid,noexec flags. (details later)|
| swap | 8G | It's like virtual memory. Stuff in RAM used a long time ago but not purged, can be "swapped out" to disk, to free up some memory for other applications that needs more. The system may not even use it, but if I have a bare-metal machine it can't be a problem if I have one. Virtual environments often don't have a swap partition. You have to plan your system's available memory so all the applications can fit in and you don't have to swap a lot/crash with out of memory errors.|
| / | 2G | No need for a lot of space. All the other important stuff is separated and has the necessary free space. I don't have a separate user home directory, as I don't want to create many users. Only one, to log into the system. I will harden this, with noexec (Red Hat only), and apply nodev and nosuid! |
| /usr | 3G | Here I have all the important system binaries. This will be read-only. If an attacker gains access to the system, often the first thing to do is altering some system binaries, to hide the traces. In this way, it's not possible (at least it will be harder, but the auditing system can detect this kind of activity.) I apply nodev here too, but we need the other grants so can't apply noexec or nosuid.|
| /var | 2G | For system logs and the package manager cache. No need much more space, if something goes wrong and the system writes a lot of logs or some attacker forces the system to write a bunch of logs, our server won't stop as there is no more free space left, all our services can run. This may have the drawbacks that we don't log the suspicious activity, so making too small /var can be a bad practice, but in this situation, 2G will be fine. I apply nodev,nosid,noexec here.|
| /tmp | 1G | Isolate the temp directory and disable any binary execution too is a must! We won't use this much, but scripts often use /tmp to do fishy stuff, in this way we can break them. This breaks compiling sources too, but we have a workaround for that. I apply nodev,nosuid,noexec here. |
| /opt | remaining space | This will be the location where we store the application data. I apply here nodev,nosuid. |

In case of UEFI boot/install a separate /boot/efi partition is also needed, in size of 200M and vfat filesystem.

I will use LVM and /opt will grow only for 90% of the available free space during the install process, so if any other logvol needs some love and extra space, I can allocate more with ease.

## fstab options for security
 - noexec: With this option set, binaries can’t be directly executed. Unfortunately, these settings can easily be circumvented by executing a non-direct path. However, mounting the /tmp directory with noexec will stop the majority of exploits designed to be executed directly from temporary file systems. (non-direct call for example if we pass the script to an interpreter. noexec prevents /tmp/script.py from running but if we use 'python /tmp/script.py' it will run, as not the script is what is executed, then python. As I said there is no such thing as a security silver bullet, but we can harden things. Maybe this is why it's called hardening... )
 - nodev: This option describes that device files are not allowed, like block or character devices. Normally these are only found under /dev and not seen on other mount points. Most mount points will work correctly when these are disabled. Even root, as /dev is in memory now as a devtmpfs.
 - nosuid: Do not use set-user-identifier (SETUID) or set-group-identifier (SETGID) bits to take effect. These bits are set with chmod (u+s, g+s) or unset (u-s, g-s) to allow a binary running under a specific user, which is not the active user itself. For example, SETUID allows a non-privileges user to use the sudo command.
 - noatime: A file has three timestamp. When the file was last modified (mtime), when the file was last changed (ctime), when the file was last accessed (atime). noatime disables the indode updates when the file was last accessed so I can gain some performance.
 - ro / rw: Mount the filesystem in either read write or read only mode.

 Special settings for /proc:
 - hidepid=2: When looking in /proc I can discover a lot of files and directories. This includes process information from other users, even sensitive details. It is better not to expose this information to everyone. Setting hidepid=2 prevents users from seeing each other's processes.

The final /etc/fstab will look like this on Red Hat:
```
/dev/mapper/cl-root     /                       xfs     rw,nosuid,noexec,nodev,seclabel,attr2,inode64,noquota 0 0
UUID=12bb8a4c-3b8a-4e23-888e-de5072313460 /boot                   xfs     ro,nodev,nosuid,noexec,noatime,seclabel,attr2,inode64,noquota 0 0
/dev/mapper/cl-opt      /opt                    xfs     rw,nodev,nosuid,noatime,seclabel,attr2,inode64,noquota 0 0
/dev/mapper/cl-tmp      /tmp                    xfs     rw,nodev,nosuid,noexec,noatime,seclabel,attr2,inode64,noquota 0 0
/dev/mapper/cl-usr      /usr                    xfs     ro,nodev,noatime,seclabel,attr2,inode64,noquota 0 0
/dev/mapper/cl-var      /var                    xfs     rw,nodev,nosuid,noexec,seclabel,attr2,inode64,noquota 0 0
/dev/mapper/cl-swap     swap                    swap    defaults        0 0
proc                    /proc                   proc    defaults,hidepid=2    0 0
```

The final /etc/fstab will look like this on openSUSE Leap 15.3:
```
/dev/system/root                           /      xfs   rw,nodev,nosuid,seclabel,attr2,inode64,noquota  0  0
/dev/system/var                            /var   xfs   rw,nodev,nosuid,noexec,seclabel,attr2,inode64,noquota  0  0
/dev/system/usr                            /usr   xfs   ro,nodev,noatime,seclabel,attr2,inode64,noquota  0  0
/dev/system/tmp                            /tmp   xfs   rw,nodev,nosuid,noexec,noatime,seclabel,attr2,inode64,noquota  0  0
/dev/system/opt                            /opt   xfs   rw,nodev,nosuid,noatime,seclabel,attr2,inode64,noquota  0  0
/dev/system/home                           /home  xfs   rw,nodev,nosuid,noexec,noatime,seclabel,attr2,inode64,noquota  0  0
UUID=cc4eebdd-a931-4294-86e5-c21512519d70  /boot  xfs   defaults  0  0
/dev/system/swap                           swap   swap  defaults  0  0
proc                    /proc                   proc    defaults,hidepid=2    0 0

```

Some of the settings like read-only /boot and /usr or noexec on / can break the installation process, so these are set later, in the post-install section by the kickstart file and not as part of the base system installation. (Note: on SUSE I can't apply noexec on root it breaks the system! On RHEL/CensOS /bin and /sbin are only symlinks, binaries are under /usr/bin or /usr/sbin, but not on SUSE.)

Later, when I need to install updates I must resolve the read-only restrictions on /boot and /usr with the following commands:
```
# mount -o remount,rw /boot
# mount -o remoun,rw /usr
```
This must be executed as root or with sudo. If I reboot the machine I don't have to re-lock them, as during boot time the system reads the /etc/fstab file and mounts the filesystems as they should be. If I don't want to reboot, by changing rw -> ro in the commands I can re-mount the filesystems as read-only.

## Thingking about the users and system access

I only need one user, who can log into the system. This non-privilegised user can then use sudo or "su -" to do system administration tasks. But always using passwords! NEVER EVER use passwordless sudo!

Also, the user can log in with ssh keys only. I don't allow any passwords. No weak nor strong passwords.
Although passwords are sent to the server in a secure manner, they are generally not complex or long enough to be resistant to repeated, persistent attackers. Modern processing power combined with automated scripts makes brute-forcing a password-protected account very possible. 

SSH key pairs are two cryptographically secure keys that can be used to authenticate a client to an SSH server. Each key pair consists of a public key and a private key.

The private key is retained by the client and should be kept absolutely secret. Any compromise of the private key will allow the attacker to log into servers that are configured with the associated public key without additional authentication. As an additional precaution, the key can be encrypted on disk with a passphrase, it's highly recommended. NEVER EVER use passwordless keys!

The associated public key can be shared freely without any negative consequences. The public key can be used to encrypt messages that only the private key can decrypt. This property is employed as a way of authenticating using the key pair. My public key is part of the kickstart script, the newly installed system will contain it and password authentication will be disabled during the installation before anyone could try to brute force it.

For generating ssh keys check: https://docs.rightscale.com/faq/How_Do_I_Generate_My_Own_SSH_Key_Pair.html

Keep your keys safe!!! Never ever share your keys!!!

## SSH 
As this service provides the access to the system, we should prepare it for good.
I DO NOT allow root login! I declare the only user who can log in, using the AllowUseres parameter. I will change the default port too (for RHEL some SELinux config is needed here, as the sshd daemon won't start if SELinux does not know about the port change). Also, it's a good practice to enable StrictMode (in most distros it's on by default), disable host based authentication and password based authentication too. So if I don't have my keys, I can't log in!!!  

(This is based on a CentOS Linux release 8.2.2004 (Core)/openSUSE Leap 15.3 fresh install... may not work for you if you only copy-paste, without knowing what you are doing, without checking your own config files). As I have a working version with all the options set in my repo, after the operating system installation I just download the pre-configured one and overwrite the original, but these are the steps I created it in the first place.
```
# Disable root login
sed -i "s/^PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config

# change ssh port
sed -i "s/^#Port.*/Port 2992/g" /etc/ssh/sshd_config

# StrictMode checks some cases before the ssh server starts. Ssh key, configuration files ownership, permission checks are performed before ssh daemon starts. If one of them fails the ssh server daemon does not starts. Strict mode is enabled by default but generally closed by system administrators. For security reasons, it should be enabled.
sed -i "s/^#StrictModes.*/StrictModes yes/g" /etc/ssh/sshd_config

# Limits the number of auth failures per connection
sed -i "s/^#MaxAuthTries.*/MaxAuthTries 3/g" /etc/ssh/sshd_config

# Disable host based authentication
sed -i "s/^#HostbasedAuthentication.*/HostbasedAuthentication no/g" /etc/ssh/sshd_config
sed -i "s/^#IgnoreRhosts.*/IgnoreRhosts yes/g" /etc/ssh/sshd_config

# Users generally prefer simple and easy to remember passwords which make attackers work easy. We want here only ssh key based login!!!
sed -i "s/^PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config

# One of the best features for ssh is forwarding X11 over remote connections. This is a very useful feature for some system administrators and users. But this can create some security holes...
sed -i "s/^X11Forwarding.*/#X11Forwarding yes/g" /etc/ssh/sshd_config

# By default public key authentication is enabled but enabling it explicitly will make it more reliable.
sed -i "s/^#PubkeyAuthentication.*/PubkeyAuthentication yes/g" /etc/ssh/sshd_config

# Allow only our user to log in. VersionAddendum has nothing to do with this, I just prefer to put the AllowUsers parameter after this one :)
sed -i "/^#VersionAddendum.*/a AllowUsers=YOURUSER" /etc/ssh/sshd_config

# After the connection is established the connection is stays in the open state forever if not closed explicitly
sed -i "s/#ClientAliveInterval.*/ClientAliveInterval 120/g" /etc/ssh/sshd_config
```
(replace YOURUSER to your username...)

## Tuning system parameters

Sysctl is an interface that allows you to make changes to a running Linux kernel. With /etc/sysctl.conf you can configure various Linux networking and system settings such as:

 - Limit network-transmitted configuration for IPv4
 - Limit network-transmitted configuration for IPv6
 - Turn on execshield protection
 - Prevent against the common ‘syn flood attack’
 - Turn on source IP address verification
 - Prevents a cracker from using a spoofing attack against the IP address of the server.
 - Logs several types of suspicious packets, such as spoofed packets, source-routed packets, and redirects.

The config is written into /etc/sysctl.d/99-sysctl.conf
```
# BOOLEAN Values:
# a) 0 (zero) - disabled / no / false
# b) Non zero - enabled / yes / true
# --------------------------------------
# Controls IP packet forwarding
net.ipv4.ip_forward = 0
 
# Do not accept source routing
net.ipv4.conf.default.accept_source_route = 0
 
# Controls the System Request debugging functionality of the kernel
kernel.sysrq = 0
 
# Controls whether core dumps will append the PID to the core filename
# Useful for debugging multi-threaded applications
kernel.core_uses_pid = 1
 
# Controls the use of TCP syncookies
# Turn on SYN-flood protections
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_synack_retries = 5
 
########## IPv4 networking start ##############
# Send redirects, if router, but this is just server
# So no routing allowed 
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
 
# Accept packets with SRR option? No
net.ipv4.conf.all.accept_source_route = 0
 
# Accept Redirects? No, this is not router
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
 
# Log packets with impossible addresses to kernel log? yes
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
 
# Ignore all ICMP ECHO and TIMESTAMP requests sent to it via broadcast/multicast
net.ipv4.icmp_echo_ignore_broadcasts = 1
 
# Prevent the common 'syn flood attack'
net.ipv4.tcp_syncookies = 1
 
# Enable source validation by reversed path, as specified in RFC1812
net.ipv4.conf.all.rp_filter = 1
 
# Controls source route verification
net.ipv4.conf.default.rp_filter = 1 
 
########## IPv6 networking start ##############
# Number of Router Solicitations to send until assuming no routers are present.
# This is host and not router
net.ipv6.conf.default.router_solicitations = 0
 
# Accept Router Preference in RA?
net.ipv6.conf.default.accept_ra_rtr_pref = 0
 
# Learn Prefix Information in Router Advertisement
net.ipv6.conf.default.accept_ra_pinfo = 0
 
# Setting controls whether the system will accept Hop Limit settings from a router advertisement
net.ipv6.conf.default.accept_ra_defrtr = 0
 
#router advertisements can cause the system to assign a global unicast address to an interface
net.ipv6.conf.default.autoconf = 0
 
#how many neighbor solicitations to send out per address?
net.ipv6.conf.default.dad_transmits = 0
 
# How many global unicast IPv6 addresses can be assigned to each interface?
net.ipv6.conf.default.max_addresses = 1
 
########## IPv6 networking ends ##############
 
#Enable ExecShield protection
#Set value to 1 or 2 (recommended) 
kernel.exec-shield = 2
kernel.randomize_va_space=2
 
# TCP and memory optimization 
# increase TCP max buffer size setable using setsockopt()
net.ipv4.tcp_rmem = 4096 87380 8388608
net.ipv4.tcp_wmem = 4096 87380 8388608
 
# increase Linux auto tuning TCP buffer limits
net.core.rmem_max = 12582912
net.core.wmem_max = 12582912
net.core.netdev_max_backlog = 9000
net.core.netdev_budget = 600
net.core.netdev_budget_usecs = 8000
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_max_syn_backlog=8192
net.ipv4.tcp_synack_retries=3
net.ipv4.tcp_retries2=6
net.ipv4.tcp_keepalive_probes=5
 
# increase system file descriptor limit    
fs.file-max = 100000
 
#Allow for more PIDs 
kernel.pid_max = 65536
 
#Increase system IP port limits
net.ipv4.ip_local_port_range = 2000 65000
 
# RFC 1337 fix
net.ipv4.tcp_rfc1337=1

# Addresses of mmap base, heap, stack and VDSO page are randomized
kernel.randomize_va_space=2

# Ignore bad ICMP errors
net.ipv4.icmp_ignore_bogus_error_responses=1

# Protects against creating or following links under certain conditions
fs.protected_hardlinks=1
fs.protected_symlinks=1

# Set console log level for kernel
kernel.printk = 4 4 1 7

# The default value of vm.swappiness is 60 and represents the percentage of the free memory before activating swap. The lower the value, the less swapping is used and the more memory pages are kept in physical memory.
vm.swappiness = 20

# https://lonesysadmin.net/2013/12/22/better-linux-disk-caching-performance-vm-dirty_ratio/
# is the absolute maximum amount of system memory that can be filled with dirty pages before everything must get committed to disk
vm.dirty_ratio = 80

# is the percentage of system memory that can be filled with “dirty” pages — memory pages that still need to be written to disk — before the pdflush/flush/kdmflush background processes kick in to write it to disk
vm.dirty_background_ratio = 5

```
## Firewall considerations (Thank you ArchWiki! https://wiki.archlinux.org/index.php/Simple_stateful_firewall)

nftables is a netfilter project that aims to replace the existing {ip,ip6,arp,eb}tables framework. It provides a new packet filtering framework, a new user-space utility (nft), and a compatibility layer for {ip,ip6}tables. It uses the existing hooks, connection tracking system, user-space queueing component, and logging subsystem of netfilter.

Firewalld or SuseFirewall2 - in contrast, because in general this can only be encountered in - is a pure frontend which comes with Red Hat/openSUSE. It's not an independent firewall by itself. It only operates by taking instructions, then turning them into nftables rules (formerly iptables), and the nftables rules ARE the firewall. So I have a choice between running "firewalld using nftables" or running "nftables only". Let's use nftables only!

The rules are in the file /etc/sysconfig/nftables.conf, but here are the details, how it is made:
```
# Flush the current ruleset
nft flush ruleset

#Add a table
nft add table inet my_table

# Add the input, forward, and output base chains. The policy for input and forward will be to drop. The policy for output will be to accept. 
nft add chain inet my_table my_input '{ type filter hook input priority 0 ; policy drop ; }'
nft add chain inet my_table my_forward '{ type filter hook forward priority 0 ; policy drop ; }'
nft add chain inet my_table my_output '{ type filter hook output priority 0 ; policy accept ; }'

# Add two regular chains that will be associated with tcp and udp
nft add chain inet my_table my_tcp_chain
nft add chain inet my_table my_udp_chain

# Related and established traffic will be accepted
nft add rule inet my_table my_input ct state related,established accept

# All loopback interface traffic will be accepted
nft add rule inet my_table my_input iif lo accept

# Drop any invalid traffic
nft add rule inet my_table my_input ct state invalid drop

# Accept ICMP and IGMP
nft add rule inet my_table my_input meta l4proto ipv6-icmp icmpv6 type '{ destination-unreachable, packet-too-big, time-exceeded, parameter-problem, mld-listener-query, mld-listener-report, mld-listener-reduction, nd-router-solicit, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert, ind-neighbor-solicit, ind-neighbor-advert, mld2-listener-report }' limit rate 4/second accept

nft add rule inet my_table my_input meta l4proto icmp icmp type '{ destination-unreachable, router-solicitation, router-advertisement, time-exceeded, parameter-problem }' limit rate 4/second accept

nft add rule inet my_table my_input ip protocol igmp accept

# New udp traffic will jump to the UDP chain
nft add rule inet my_table my_input meta l4proto udp ct state new jump my_udp_chain

# New tcp traffic will jump to the TCP chain
nft add rule inet my_table my_input 'meta l4proto tcp tcp flags & (fin|syn|rst|ack) == syn ct state new jump my_tcp_chain'

# Reject all traffic that was not processed by other rules
nft add rule inet my_table my_input meta l4proto udp reject
nft add rule inet my_table my_input meta l4proto tcp reject with tcp reset
nft add rule inet my_table my_input counter reject with icmpx type port-unreachable

# Allow ssh&Prysm&Geth TCP ports
nft add rule inet my_table my_tcp_chain tcp dport 2992 counter limit rate 4/second accept
nft add rule inet my_table my_tcp_chain tcp dport 30303 counter accept
nft add rule inet my_table my_tcp_chain tcp dport 13000 counter accept

# Allow Prysm&Geth UDP ports
nft add rule inet my_table my_udp_chain udp dport 30303 counter accept
nft add rule inet my_table my_udp_chain udp dport 12000 counter accept
```
To use native nftables I disable and mask the firewalld service, and enable the nftables service in the kickstart file for RHEL.
```
systemctl disable firewalld
systemctl mask --now firewalld
systemctl enable nftables
```
For openSUSE it is in the AutoYast config file, in the disabled services section.

## Fail2ban - ssh protection

Fail2ban scans log files (e.g. /var/log/secure or journald logs) and bans IPs that show the malicious signs -- too many password failures, seeking for exploits, etc. Generally, Fail2Ban is then used to update firewall rules to reject the IP addresses for a specified amount of time, although any arbitrary other action (e.g. sending an email) could also be configured. Out of the box, Fail2Ban comes with filters for various services (apache, courier, ssh, etc).

Some distros may have an outdated version in the distro's repository. OpenSUSE Leap 15.3 must use an additional repository to get the latest version, it's in the AutoYast file.

To override the defaults, I don't change the main configs, as a version update may replace the config/filter files. Fail2ban checks if there is a .local file with the same name. So to modify some settings, I just create a jail.local file, which can contain the same settings as jail.conf, but this will override the defaults. In this file I can define the default backend, the default ban action to use nftables and some filters, like the sshd filter.

/etc/fail2ban/jail.local
```
# Ban IP/hosts for 24 hour ( 24h*3600s = 86400s):
bantime = 86400
backend = systemd

# An ip address/host is banned if it has generated "maxretry" during the last "findtime" seconds.
findtime = 600
maxretry = 3

# "ignoreip" can be a list of IP addresses, CIDR masks or DNS hosts. Fail2ban
# will not ban a host which matches an address in this list. Several addresses
# can be defined using space (and/or comma) separator. For example, add your
# static IP address that you always use for login such as 103.1.2.3
ignoreip = 9.10.11.12

# configure nftables
banaction = nftables-multiport
chain     = input


# Enable custom sshd protection (failed preauth messages are not present in journal...)
[fail2ban-sshd]
enabled  = true
port     = 2992
filter   = sshd[mode=aggressive]
maxretry = 3
findtime = 600
bantime  = 86400

```
Fail2Ban allows me to list IP addresses which should be ignored. This can be useful for testing purposes and can help avoid locking clients (or myself) out unnecessarily. For example, if an attacker knows my IP, he/she or it can send spoofed packages and lock me out. The parameter 'ignoreip' can prevent this. 

In /etc/fail2ban/action.d/nftables-common.local I can connect fail2ban with nftables and define which nftables tables and chains to use. (family and tables names are alligned to my nftables config)
```
[Init]
# Definition of the table used
nftables_family = ip
nftables_table  = fail2ban

# Drop packets 
blocktype       = drop

# Remove nftables prefix. Set names are limited to 15 char so we want them all
nftables_set_prefix =
```

Lastly, I have to create the defined new nftables table and chain, where fail2ban will work and include this in the main nftables config (as an alternative, I can paste the whole table definition to the end of the /etc/sysconfig/nftables file, so all firewall configuration is in the same file).

/etc/nftables/fail2ban.conf
```
#!/usr/sbin/nft -f
table ip fail2ban {
        chain input {
                # Assign a high priority to reject as fast as possible and avoid more complex rule evaluation
                type filter hook input priority 100;
        }
}
```
I could set up mail sending action, but I don't want to get notified after every banned IP. Daily reports will be enough from LogWatch and the Auditd daemon.

## Auditing the system

Our system comes auditd installed by default and that's a good thing for us. Auditd can watch over the system for events that modify Date and Time information, events that modify User/Group information, events that modify the system's network environment, collect login and logout events, collect unsuccessful unauthorized access attempts to files, etc.

It's a really handy tool and also can generate reports and send them via mail, so we can check what is happening in our system.

All the configs are in /etc/audit/rules.d/audit.rules
I "lock" the config (-e 2 parameter), so after the service started, no one can edit/add rules without editing the lock and/or restarting the service or the machine. And that will trigger a lot of alerts... I hope I never get this kind of alert.

```
## First rule - delete all
-D

## Increase the buffers to survive stress events.
## Make this bigger for busy systems
-b 8192

## This determine how long to wait in burst of events
--backlog_wait_time 60000

## Set failure mode to syslog
-f 1

## Enable auditd and lock the config, preventing any modifications
-e 2

## This rule suppresses the time-change event when chrony does time updates
-a never,exit -F arch=b64 -S adjtimex -F uid=chrony -F subj_type=chronyd_t
-a never,exit -F arch=b32 -S adjtimex -F uid=chrony -F subj_type=chronyd_t

# Record Events That Modify Date and Time Information
-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change
-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change
-a always,exit -F arch=b64 -S clock_settime -k time-change
-a always,exit -F arch=b32 -S clock_settime -k time-change -w /etc/localtime -p wa -k time-change

# Record Events That Modify User/Group Information
-w /etc/group -p wa -k identity
-w /etc/passwd -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/security/opasswd -p wa -k identity

# Record Events That Modify the System's Network Environment
-a exit,always -F arch=b64 -S sethostname -S setdomainname -k system-locale
-a exit,always -F arch=b32 -S sethostname -S setdomainname -k system-locale
-w /etc/issue -p wa -k system-locale -w /etc/issue.net -p wa -k system-locale
-w /etc/hosts -p wa -k system-locale -w /etc/network -p wa -k system-locale

# Record Events That Modify the System's Mandatory Access Controls
-w /etc/selinux/ -p wa -k MAC-policy

# Collect Login and Logout Events
-w /var/log/faillog -p wa -k logins
-w /var/log/lastlog -p wa -k logins
-w /var/log/tallylog -p wa -k logins

# Collect Session Initiation Information
-w /var/run/utmp -p wa -k session
-w /var/log/wtmp -p wa -k session
-w /var/log/btmp -p wa -k session

# Collect Discretionary Access Control Permission Modification Events
-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=500 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=500 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=500 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=500 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=500 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=500 -F auid!=4294967295 -k perm_mod

# Collect Unsuccessful Unauthorized Access Attempts to Files
-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=500 -F auid!=4294967295 -k access
-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=500 -F auid!=4294967295 -k access
-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=500 -F auid!=4294967295 -k access
-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=500 -F auid!=4294967295 -k access

# Collect Unsuccessful File System Mounts
-a always,exit -F arch=b64 -S mount -F auid>=500 -F auid!=4294967295 -k mounts
-a always,exit -F arch=b32 -S mount -F auid>=500 -F auid!=4294967295 -k mounts

# This rule suppresses events that originate on the below file systems.
# Typically you would use this in conjunction with rules to monitor
# kernel modules. The filesystem listed are known to cause hundreds of
# path records during kernel module load. As an aside, if you do see the
# tracefs or debugfs module load and this is a production system, you really
# should look into why its getting loaded and prevent it if possible.
-a never,filesystem -F fstype=tracefs
-a never,filesystem -F fstype=debugfs

# Collect File Deletion Events by User
-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=500 -F auid!=4294967295 -k delete
-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=500 -F auid!=4294967295 -k delete

# Collect Changes to System Administration Scope
-w /etc/sudoers -p wa -k scope

# Collect Kernel Module Loading and Unloading
-w /sbin/insmod -p x -k modules
-w /sbin/rmmod -p x -k modules
-w /sbin/modprobe -p x -k modules

```

Creating reports of the events I can use the aureport utility.
```
aureport -ts today -te now --summary -i
```
This command shows what happend today.\
 - ts yesterday: so the report will start from yesterday
 - te now: so the report will contain event up until now
 - summary: a summary of all events

There is a lot of information which can be drained from aureport. Check this site for more details, to create your own reports (https://www.tecmint.com/create-reports-from-audit-logs-using-aureport-on-centos-rhel/)

To send mails, I use sendgrid and mailx. The mailx config file is /root/.mailrc (ofc I need SendGrid account, and apikey!), I don't want to create global config. Only the root user can use cron too, so only the root user can send mails via SendGrid.


## Logwatch (Optional)

LogWatch is a Perl-based log management tool that analyses a server’s log files and generates a daily report which summarises and reports on your system’s log activity. It does not provide real-time alerts but instead is most often used to send a short daily digest of server’s log activity to a system administrator.

The default config file is /usr/share/logwatch/default.conf/logwatch.conf, but - just like fail2ban - there is a local config, as packege updates may overwrite the global config, my modifications are safe if I put them into /etc/logwatch/conf/logwatch.conf

I set details level to almost max (8), and change the mailer and parameters to send the reports in email. Also I can define the services I want to include the report or just send everything by default (but the kernel log is massive!).

```
Output = mail
mailer = "/usr/bin/mailx -s 'LogWatch report(StakingNode)' your@email"
Range = Today
Detail = 8
```

I mark this step optional, as most of our applications will use journald logs and we won't have much traditional log files, but it's a handy tool.
Often I just use the disk usage report, but using the following command in the aureport script, we can get all the informations in one email:
```
# df -h -l -x tmpfs

Filesystem               Size  Used Avail Use% Mounted on
devtmpfs                 4.0M     0  4.0M   0% /dev
/dev/mapper/system-root  2.0G  108M  1.9G   6% /
/dev/mapper/system-usr   3.0G  910M  2.2G  30% /usr
/dev/mapper/system-tmp  1014M   35M  980M   4% /tmp
/dev/mapper/system-home  2.0G   35M  2.0G   2% /home
/dev/mapper/system-var   2.0G  124M  1.9G   7% /var
/dev/mapper/system-opt    36G  2.0G   34G   6% /opt
/dev/sda2                253M   64M  190M  25% /boot
```

## My daily reports

Using a small script, I can send daily reports (/root/bin/reports.sh):

```
#!/bin/bash
LOGFILE=/tmp/daily.log
echo > $LOGFILE

/usr/sbin/logwatch >> $LOGFILE
/usr/sbin/aureport --input-logs -ts yesterday 00:00:00 -te now --summary -i >> $LOGFILE
/usr/sbin/aureport --input-logs -ts yesterday 00:00:00 -te now -k --summary >> $LOGFILE
/usr/sbin/aureport --input-logs -ts yesterday 00:00:00 -te now -x --summary >> $LOGFILE
/usr/sbin/aureport --input-logs -ts yesterday 00:00:00 -te now --mac --summary >> $LOGFILE
/usr/sbin/aureport --input-logs -ts yesterday 00:00:00 -te now -i --login|tail -n5 >> $LOGFILE

cat ${LOGFILE} | /usr/bin/mailx -s 'Daily report (eth2)' lyynxxx@gmail.com

echo > $LOGFILE
```

The script runs every day, a few minutes after Midnight.

```
# crontab -l

04 0 * * * /root/bin/reports.sh
```

## Services users

Every service (geth, the beacon chanin client and the validator client) will run under their own service user. Service users don't have a home directory or grant to login/use shell. Their only purpose is to run one application and nothing more, as limited as possible. I create systemd services to keep them running and start them at boot time.

Using systemd I can apply some extra security settings and try to prevent the applications to sniff around (if compromised) in directories where they should not do anything.
```
[Service]
ExecStart=...
InaccessibleDirectories=/home
ReadOnlyDirectories=/var /etc
...
```
With the ReadOnlyDirectories= and InaccessibleDirectories= options, it is possible to make the specified directories inaccessible for writing resp. both reading and writing to the service. With these two configuration lines, the whole tree below /home becomes inaccessible to the service (i.e. the directory will appear empty and with 000 access mode), and the tree below /var and /etc becomes read-only. I can define more folders, separate by spaces.

The kickstart file will create separate users both for the beacon chain and the validator and for any other service I need to run on this system. 

If you want to compile from source, you can, but personally in prod I don't like any compiler or building tool if it's not essential and the system can't work without them.

noexec on /tmp will break any compiling attempt. Instead of disabling this security feature, set up your own TEMP space and tell the system, you don't want to use /tmp (but I have noexec on / too... :D that is maybe work unlocking for a while ):
```
mkdir /home/YOURUSER/tmp
chown YOURUSER:YOURUSER /home/YOURUSER/tmp
chmod 750 /home/YOURUSER/tmp

echo "export TMP=/home/YOURUSER/tmp;" >> /home/YOURUSER/.bashrc
echo "export TEMP=/home/YOURUSER/tmp;" >> /home/YOURUSER/.bashrc
echo "export TMPDIR=/home/YOURUSER/tmp;" >> /home/YOURUSER/.bashrc
echo "export PATH=/home/YOURUSER/go/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin" >> /home/YOURUSER/.bashrc
```
So compiling isn't a problem any more.

The eth2deposit-cli tool also breaks with noexec on /tmp!
```
lyynxxx@tEth2:/opt/tmp/eth2deposit-cli-256ea21-linux-amd64> ./deposit
./deposit: error while loading shared libraries: libz.so.1: failed to map segment from shared object
```

### Too many open files...

systemd completely ignores /etc/security/limits*.
In /proc I can check the process limits. First I need to find the PID, the process ID.
```
[root@eth2 ~]# ps -efa | grep beacon
beacon    3909     1  0 11:17 ?        00:00:33 /opt/beacon-chain/bin/prysm.sh --p2p-host-ip=81.182.121.253 --datadir=/opt/beacon-chain/data --http-web3provider=http://127.0.0.1:8545 --accept-terms-of-use
```
Then check the limits for process 3909
```
[root@eth2 ~]# cat /proc/3909/limits
Limit                     Soft Limit           Hard Limit           Units
Max cpu time              unlimited            unlimited            seconds
Max file size             unlimited            unlimited            bytes
Max data size             unlimited            unlimited            bytes
Max stack size            8388608              unlimited            bytes
Max core file size        unlimited            unlimited            bytes
Max resident set          unlimited            unlimited            bytes
Max processes             63809                63809                processes
**Max open files            1024                 262144               files**
Max locked memory         65536                65536                bytes
Max address space         unlimited            unlimited            bytes
Max file locks            unlimited            unlimited            locks
Max pending signals       63809                63809                signals
Max msgqueue size         819200               819200               bytes
Max nice priority         0                    0
Max realtime priority     0                    0
Max realtime timeout      unlimited            unlimited            us
```

To allow a service open more then the default 1024 files, I need to add some extra parameters into the service section. Don't rush 100K open files for all processes, start with 5X (1024 *5 = 5120).

```
LimitNOFILE=5120
LimitNPROC=5120
```
Reload the systemd unit and restart the service.
```
systemctl daemon-reload beacon
systemct restart beacon

[root@eth2 ~]# cat /proc/4240/limits
Limit                     Soft Limit           Hard Limit           Units
Max cpu time              unlimited            unlimited            seconds
Max file size             unlimited            unlimited            bytes
Max data size             unlimited            unlimited            bytes
Max stack size            8388608              unlimited            bytes
Max core file size        unlimited            unlimited            bytes
Max resident set          unlimited            unlimited            bytes
Max processes             5120                 5120                 processes
Max open files            5120                 5120                 files
Max locked memory         65536                65536                bytes
Max address space         unlimited            unlimited            bytes
Max file locks            unlimited            unlimited            locks
Max pending signals       63809                63809                signals
Max msgqueue size         819200               819200               bytes
Max nice priority         0                    0
Max realtime priority     0                    0
Max realtime timeout      unlimited            unlimited            us


```

Also worth calculate the limits not to exceed the system wide limits otherwise the system will not respond.
All your limints set < fs.file-max in sysctl config!

If you are not careful, you can run into this issue:

```
Nov 29 10:22:30 eth2.vm prysm.sh[14483]: time="2020-11-29 10:22:30" level=info msg="Node started p2p server" multiAddr="/ip4/192.168.0.92/tcp/13000/p2p/16Uiu2HAmRKWHdtxuQpMezkogXgjoT3xsggX2dSeWtvmdNYRFci8P" prefix=p2p
Nov 29 10:22:38 eth2.vm prysm.sh[14483]: time="2020-11-29 10:22:38" level=error msg="Unable to process past logs Could not process deposit log: could not get correct merkle index: latest index observed is not accurate, wanted 25885, but received  22153" prefix=powchain
Nov 29 10:22:39 eth2.vm prysm.sh[14483]: 2020-11-29T10:22:39.171+0100        ERROR        basichost        failed to resolve local interface addresses        {"error": "route ip+net: netlinkrib: too many open files in system"}
Nov 29 10:22:44 eth2.vm prysm.sh[14483]: 2020-11-29T10:22:44.173+0100        ERROR        basichost        failed to resolve local interface addresses        {"error": "route ip+net: netlinkrib: too many open files in system"}
Nov 29 10:22:44 eth2.vm prysm.sh[14483]: time="2020-11-29 10:22:44" level=info msg="Connected to eth1 proof-of-work chain" endpoint="http://127.0.0.1:8545" prefix=powchain
Nov 29 10:22:47 eth2.vm prysm.sh[14483]: time="2020-11-29 10:22:47" level=error msg="Unable to process past logs Could not process deposit log: could not get correct merkle index: latest index observed is not accurate, wanted 25885, but received  22153" prefix=powchain
Nov 29 10:22:49 eth2.vm prysm.sh[14483]: 2020-11-29T10:22:49.171+0100        ERROR        basichost        failed to resolve local interface addresses        {"error": "route ip+net: netlinkrib: too many open files in system"}
Nov 29 10:22:53 eth2.vm prysm.sh[14483]: time="2020-11-29 10:22:53" level=info msg="Connected to eth1 proof-of-work chain" endpoint="http://127.0.0.1:8545" prefix=powchain
Nov 29 10:22:54 eth2.vm prysm.sh[14483]: 2020-11-29T10:22:54.171+0100        ERROR        basichost        failed to resolve local interface addresses        {"error": "route ip+net: netlinkrib: too many open files in system"}
Nov 29 10:22:57 eth2.vm prysm.sh[14483]: time="2020-11-29 10:22:57" level=error msg="Unable to process past logs Could not process deposit log: could not get correct merkle index: latest index observed is not accurate, wanted 25885, but received  22153" prefix=powchain
Nov 29 10:22:59 eth2.vm prysm.sh[14483]: 2020-11-29T10:22:59.171+0100        ERROR        basichost        failed to resolve local interface addresses        {"error": "route ip+net: netlinkrib: too many open files in system"}
^C
[YOURUSER@eth2 ~]$ cat /proc/sys/fs/file-max
-bash: start_pipeline: pgrp pipe: Too many open files in system
-bash: /usr/bin/cat: Too many open files in system
[YOURUSER@eth2 ~]$ su -
-bash: start_pipeline: pgrp pipe: Too many open files in system
-bash: /usr/bin/su: Too many open files in system
[YOURUSER@eth2 ~]$ w
-bash: start_pipeline: pgrp pipe: Too many open files in system
-bash: /usr/bin/w: Too many open files in system

```

Only hard reset can help you to gain back control over the machine...
