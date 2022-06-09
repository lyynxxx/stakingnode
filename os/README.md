As I see there isn't such thing as a security "silver bullet", what solves everything. I must assume, my system is not unbreakable, therefore I need to create more security layer. None of the layers itself are enough, but together they can mitigate a lot of the attack vectors. A "default" install is never good enough!

The followings are generic tips, they work on almost any linux systems.

# Planing the partitions
Security begins even before I start the installation. During the installation process, I have an option to define the different partitions, filesystem types and sizes. I can apply different restrictions or fine tune the behavior of the filesystem. Separating the major system folders can help more then most people thinks. Before I start anything, let's think about partitions a bit.


| Partition | Size | What for |
| ------ | ------ | ------ |
| /boot | 512M | Isolated boot partition for the kernel and the boot config files. I will make this read-only and unlock it only when I need to update the system. Also apply nodev,nosuid,noexec flags. (details later)|
| swap | 8-16G | It's like virtual memory. Stuff in RAM used a long time ago but not purged, can be "swapped out" to disk, to free up some memory for other applications that needs more. The system may not even use it, but if I have a bare-metal machine it can't be a problem if I have one. Virtual environments often don't have a swap partition. You have to plan your system's available memory so all the applications can fit in and you don't have to swap a lot/crash with out of memory errors.|
| / | 2-3G | No need for a lot of space. All the other important stuff is separated and has the necessary free space. I don't have a separate user home directory, as I don't want to create many users. Only one, to log into the system. I will harden this, with noexec (Red Hat only, on SuSE you need a /home partition with noexec), and apply nodev and nosuid! |
| /usr | 3-4G | Here I have all the important system binaries. This will be read-only. If an attacker gains access to the system, often the first thing to do is altering some system binaries, to hide the traces. In this way, it's not possible (at least it will be harder, but the auditing system can detect this kind of activity.) I apply nodev here too, but we need the other grants so can't apply noexec or nosuid.|
| /var | 2-4G | For system logs and the package manager cache. No need much more space, if something goes wrong and the system writes a lot of logs or some attacker forces the system to write a bunch of logs, our server won't stop as there is no more free space left, all our services can run. This may have the drawbacks that we don't log the suspicious activity, so making too small /var can be a bad practice, but in this situation, 2G will be fine. I apply nodev,nosid,noexec here.|
| /tmp | 1G | Isolate the temp directory and disable any binary execution too is a must! We won't use this much, but scripts often use /tmp to do fishy stuff, in this way we can break them. This breaks compiling sources too, but we have a workaround for that. I apply nodev,nosuid,noexec here. |
| /opt | remaining space | This will be the location where we store the application data. I apply here nodev,nosuid. |

In case of UEFI boot/install a separate /boot/efi partition is also needed, in size of 200M and vfat filesystem.

I will use LVM and /opt will grow only for 90% of the available free space during the install process, so if any other logvol needs some love and extra space, I can allocate more with ease.

## fstab options for security
 - noexec: With this option set, binaries can’t be directly executed. Unfortunately, these settings can easily be circumvented by executing a non-direct path. However, mounting the /tmp directory with noexec will stop the majority of exploits designed to be executed directly from temporary file systems. (non-direct call for example if we pass the script to an interpreter. noexec prevents /tmp/script.py from running but if we use 'python /tmp/script.py' it will run, as not the script is what is executed, then python. As I said there is no such thing as a security silver bullet, but we can harden things. Maybe this is why it's called hardening... )
 - nodev: This option describes that device files are not allowed, like block or character devices. Normally these are only found under /dev and not seen on other mount points. Most mount points will work correctly when these are disabled. Even root, as /dev is in memory now as a devtmpfs.
 - nosuid: Do not use set-user-identifier (SETUID) or set-group-identifier (SETGID) bits to take effect. These bits are set with chmod (u+s, g+s) or unset (u-s, g-s) to allow a binary running under a specific user, which is not the active user itself. For example, SETUID allows a non-privileges user to use the sudo command.
 - noatime: A file has three timestamp. When the file was last modified (mtime), when the file was last changed (ctime), when the file was last accessed (atime). noatime disables the indode updates when the file was last accessed so I can gain some performance and extend the SSD lifetime.
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

Some of the settings like read-only /boot and /usr or noexec on / can break the automated installation process, so these are set later, in the post-install section by the kickstart file and not as part of the base system installation. (Note: on SUSE I can't apply noexec on root it breaks the system! On RHEL/CensOS /bin and /sbin are only symlinks, binaries are under /usr/bin or /usr/sbin, but not on SUSE.)

Later, when I need to install updates I must resolve the read-only restrictions on /boot and /usr with the following commands:
```
# mount -o remount,rw /boot
# mount -o remoun,rw /usr
```
This must be executed as root or with sudo. If I reboot the machine I don't have to re-lock them, as during boot time the system reads the /etc/fstab file and mounts the filesystems as they should be. If I don't want to reboot, by changing rw -> ro in the commands I can re-mount the filesystems as read-only.

## Hide some commands
As I'm paranoid AF, I don't want to log the commands I use to unlock my system before updates (remount /usr and /boot in read-write mode) or before any other software installation or user creation/password change (immutable /etc/passwd).
If I use an extra space before the commands, they are not placed into the history file, they will be hidden!
So if anyone cracks my node and tries to add a new user, and they don't think about immutable files, the system won't be altered much. This can buy me some time to mitigate the original attack vector.

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
# Sources:
# https://madaidans-insecurities.github.io/guides/linux-hardening.html
# https://www.cyberciti.biz/tips/linux-security.html

### Kernel protection

# A kernel pointer points to a specific location in kernel memory. These can be very useful in exploiting the kernel, but kernel pointers are not hidden by default.
kernel.kptr_restrict=2

# dmesg is the kernel log. It exposes a large amount of useful kernel debugging information, but this can often leak sensitive information. Changing the above sysctl restricts the kernel log to the CAP_SYSLOG capability. 
kernel.dmesg_restrict=1

# Set console log level for kernel. Malware that is able to record the screen during boot may be able to abuse this to gain higher privileges. This option prevents those information leaks
kernel.printk=3 3 3 3

# eBPF exposes quite large attack surface. These sysctls restrict eBPF to the CAP_BPF capability (CAP_SYS_ADMIN on kernel versions prior to 5.8) and enable JIT hardening techniques, such as constant blinding. 
kernel.unprivileged_bpf_disabled=1
net.core.bpf_jit_harden=2

# The userfaultfd() syscall is often abused to exploit use-after-free flaws. This sysctl is used to restrict this syscall to the CAP_SYS_PTRACE capability. 
vm.unprivileged_userfaultfd=0

# This restricts loading TTY line disciplines to the CAP_SYS_MODULE capability to prevent unprivileged attackers from loading vulnerable line disciplines with the TIOCSETD ioctl
dev.tty.ldisc_autoload=0

# kexec is a system call that is used to boot another kernel during runtime. This functionality can be abused to load a malicious kernel and gain arbitrary code execution in kernel mode, so this sysctl disables it.
kernel.kexec_load_disabled=1

# The SysRq key exposes a lot of potentially dangerous debugging functionality to unprivileged users. Contrary to common assumptions, SysRq is not only an issue for physical attacks, as it can also be triggered remotely.
kernel.sysrq=4

# User namespaces are a feature in the kernel which aim to improve sandboxing and make it easily accessible for unprivileged users. However, this feature exposes significant kernel attack surface for privilege escalation, so this sysctl restricts the usage of user namespaces to the CAP_SYS_ADMIN capability. For unprivileged sandboxing, it is instead recommended to use a setuid binary with little attack surface to minimise the potential for privilege escalation.
## If your kernel does not include this patch, you can alternatively disable user namespaces completely (including for root) by setting:
# user.max_user_namespaces=0. 
kernel.unprivileged_userns_clone=0

# Performance events add considerable kernel attack surface and have caused abundant vulnerabilities. This sysctl restricts all usage of performance events to the CAP_PERFMON capability (CAP_SYS_ADMIN on kernel versions prior to 5.8).
## sysctl also requires a kernel patch that is only available on certain distributions. Otherwise, this setting is equivalent to kernel.perf_event_paranoid=2, which only restricts a subset of this functionality. 
kernel.perf_event_paranoid=3

# Controls the System Request debugging functionality of the kernel
kernel.sysrq = 0

# Controls whether core dumps will append the PID to the core filename
# Useful for debugging multi-threaded applications
kernel.core_uses_pid = 1


### Network


# This helps protect against SYN flood attacks, which are a form of denial-of-service attack, in which an attacker sends a large amount of bogus SYN requests in an attempt to consume enough resources to make the system unresponsive to legitimate traffic
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_synack_retries = 5

# RFC 1337 fix. This protects against time-wait assassination by dropping RST packets for sockets in the time-wait state. 
net.ipv4.tcp_rfc1337=1

# Controls IP packet forwarding, it's not a router!
net.ipv4.ip_forward = 0
ipv4.conf.all.forwarding = 0
 
# Do not accept source routing
net.ipv4.conf.default.accept_source_route = 0
 
# These enable source validation of packets received from all interfaces of the machine. This protects against IP spoofing, in which an attacker sends a packet with a fraudulent IP address.
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# These disable ICMP redirect acceptance and sending to prevent man-in-the-middle attacks and minimise information disclosure. Send redirects, if router, but this is just server, so no routing allowed!
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.default.accept_redirects=0
net.ipv4.conf.all.secure_redirects=0
net.ipv4.conf.default.secure_redirects=0
net.ipv6.conf.all.accept_redirects=0
net.ipv6.conf.default.accept_redirects=0
net.ipv4.conf.all.send_redirects=0
net.ipv4.conf.default.send_redirects=0
 
# This setting makes your system ignore all ICMP requests to avoid Smurf attacks, make the device more difficult to enumerate on the network and prevent clock fingerprinting through ICMP timestamps. 
net.ipv4.icmp_echo_ignore_all=1

# Accept packets with SRR option? No
net.ipv4.conf.all.accept_source_route = 0

# Source routing is a mechanism that allows users to redirect network traffic. As this can be used to perform man-in-the-middle attacks in which the traffic is redirected for nefarious purposes. This settings disable this functionality. 
net.ipv4.conf.all.accept_source_route=0
net.ipv4.conf.default.accept_source_route=0
net.ipv6.conf.all.accept_source_route=0
net.ipv6.conf.default.accept_source_route=0

# This disables TCP SACK. SACK is commonly exploited and unnecessary in many circumstances, so it should be disabled if it is not required.
net.ipv4.tcp_sack=0
net.ipv4.tcp_dsack=0
net.ipv4.tcp_fack=0

# Ignore all ICMP ECHO and TIMESTAMP requests sent to it via broadcast/multicast
net.ipv4.icmp_echo_ignore_broadcasts = 1
 
# Disable ipv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
 
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

# TCP timestamps also leak the system time. The kernel attempted to fix this by using a random offset for each connection, but this is not enough to fix the issue. Thus, TCP timestamps should be disabled.
net.ipv4.tcp_timestamps=0

### User space


# ptrace is a system call that allows a program to alter and inspect another running process, which allows attackers to trivially modify the memory of other running programs. This restricts usage of ptrace to only processes with the CAP_SYS_PTRACE capability. Alternatively, set the sysctl to 3 to disable ptrace entirely. 
kernel.yama.ptrace_scope=2

# ASLR is a common exploit mitigation which randomises the position of critical parts of a process in memory. This can make a wide variety of exploits harder to pull off, as they first require an information leak. The above settings increase the bits of entropy used for mmap ASLR, improving its effectiveness. 
vm.mmap_rnd_bits=32
vm.mmap_rnd_compat_bits=16

# This only permits symlinks to be followed when outside of a world-writable sticky directory, when the owner of the symlink and follower match or when the directory owner matches the symlink's owner. This also prevents hardlinks from being created by users that do not have read/write access to the source file. 
fs.protected_symlinks=1
fs.protected_hardlinks=1

# These prevent creating files in potentially attacker-controlled environments, such as world-writable directories, to make data spoofing attacks more difficult. 
fs.protected_fifos=2
fs.protected_regular=2


### Other...


# increase system file descriptor limit    
fs.file-max = 100000
 
#Allow for more PIDs 
kernel.pid_max = 65536
 
#Increase system IP port limits
net.ipv4.ip_local_port_range = 2000 65000
 
# Addresses of mmap base, heap, stack and VDSO page are randomized
kernel.randomize_va_space=2

# Ignore bad ICMP errors
net.ipv4.icmp_ignore_bogus_error_responses=1

# The default value of vm.swappiness is 60 and represents the percentage of the free memory before activating swap. The lower the value, the less swapping is used and the more memory pages are kept in physical memory.
vm.swappiness = 20

# https://lonesysadmin.net/2013/12/22/better-linux-disk-caching-performance-vm-dirty_ratio/
# is the absolute maximum amount of system memory that can be filled with dirty pages before everything must get committed to disk
vm.dirty_ratio = 80

# is the percentage of system memory that can be filled with “dirty” pages — memory pages that still need to be written to disk — before the pdflush/flush/kdmflush background processes kick in to write it to disk
vm.dirty_background_ratio = 5

```

## Boot parameters

Boot parameters pass settings to the kernel at boot using your bootloader. Some settings can be used to increase security, similar to sysctl.
The following settings are recommended to increase security.

Using GRUB as bootloader, edit /etc/default/grub, and add parameters to the GRUB_CMDLINE_LINUX_DEFAULT= line.

 - init_on_alloc=1 init_on_free=1
This enables zeroing of memory during allocation and free time, which can help mitigate use-after-free vulnerabilities and erase sensitive information in memory. 

 - page_alloc.shuffle=1
This option randomises page allocator freelists, improving security by making page allocations less predictable. This also improves performance.

 - pti=on
This enables Kernel Page Table Isolation, which mitigates Meltdown and prevents some KASLR bypasses

 - randomize_kstack_offset=on
This option randomises the kernel stack offset on each syscall, which makes attacks that rely on deterministic kernel stack layout significantly more difficult, such as the exploitation of CVE-2019-18683.

 - vsyscall=none
This disables vsyscalls, as they are obsolete and have been replaced with vDSO. vsyscalls are also at fixed addresses in memory, making them a potential target for ROP attacks.

 - debugfs=off
This disables debugfs, which exposes a lot of sensitive information about the kernel. 

 - oops=panic
Sometimes certain kernel exploits will cause what is known as an "oops". This parameter will cause the kernel to panic on such oopses, thereby preventing those exploits. However, sometimes bad drivers cause harmless oopses which would result in your system crashing, meaning this boot parameter can only be used on certain hardware

 - module.sig_enforce=1
This only allows kernel modules that have been signed with a valid key to be loaded, which increases security by making it much harder to load a malicious kernel module. This prevents all out-of-tree kernel modules, including DKMS modules from being loaded unless you have signed them, meaning that modules such as the VirtualBox or Nvidia drivers may not be usable, although that may not be important, depending on your setup.

 - lockdown=confidentiality
The kernel lockdown LSM can eliminate many methods that user space code could abuse to escalate to kernel privileges and extract sensitive information. This LSM is necessary to implement a clear security boundary between user space and the kernel. The above option enables this feature in confidentiality mode, the strictest option. This implies module.sig_enforce=1. 

 - mce=0
This causes the kernel to panic on uncorrectable errors in ECC memory which could be exploited. This is unnecessary for systems without ECC memory.

 - ipv6.disable=1
This disables the entire IPv6 stack which may not be required if you have not migrated to it.


## Application sandboxing
While systemd is unrecommended, some may be unable to switch... or don't want to switch. It's your choice. I don't want to tell you what to use. Red Hat and openSUSE also use systemd.
!!!You cannot just copy this example configuration into yours. Each service's requirements differ, and the sandbox has to be fine-tuned for each of them specifically!!!
(Well... I have tested these with my setup and with my needs, so following my guide, you can download the prepared service files... but you got the point... every system is different!)

```
[Service]
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
ProtectSystem=strict
ProtectHome=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true
ProtectKernelLogs=true
ProtectHostname=true
ProtectClock=true
ProtectProc=invisible
ProcSubset=pid
PrivateTmp=true
PrivateUsers=true
PrivateDevices=true
PrivateIPC=true
MemoryDenyWriteExecute=true
NoNewPrivileges=true
LockPersonality=true
RestrictRealtime=true
RestrictSUIDSGID=true
RestrictAddressFamilies=AF_INET
RestrictNamespaces=true
SystemCallFilter=write read openat close brk fstat lseek mmap mprotect munmap rt_sigaction rt_sigprocmask ioctl nanosleep select access execve getuid arch_prctl set_tid_address set_robust_list prlimit64 pread64 getrandom
SystemCallArchitectures=native
UMask=0077
IPAddressDeny=any
AppArmorProfile=/etc/apparmor.d/usr.bin.example
```

What all these settings are for:
 - CapabilityBoundingSet= — Specifies the capabilities the process is given.
 - ProtectHome=true — Makes all home directories inaccessible.
 - ProtectKernelTunables=true — Mounts kernel tunables, such as those modified through sysctl, as read-only.
 - ProtectKernelModules=true — Denies module loading and unloading.
 - ProtectControlGroups=true — Mounts all control group hierarchies as read-only.
 - ProtectKernelLogs=true — Prevents accessing the kernel logs.
 - ProtectHostname=true — Prevents changes to the system hostname.
 - ProtectClock — Prevents changes to the system clock.
 - ProtectProc=invisible — Hides all outside processes.
 - ProcSubset=pid — Permits access to only the pid subset of /proc.
 - PrivateTmp=true — Mounts an empty tmpfs over /tmp and /var/tmp, therefore hiding their previous contents.
 - PrivateUsers=true — Sets up an empty user namespace to hide other user accounts on the system.
 - PrivateDevices=true — Creates a new /dev mount with minimal devices present.
 - PrivateIPC=true — Sets up an IPC namespace to isolate IPC resources.
 - MemoryDenyWriteExecute=true — Enforces a memory W^X policy.
 - NoNewPrivileges=true — Prevents escalating privileges.
 - LockPersonality=true — Locks down the personality() syscall to prevent switching execution domains.
 - RestrictRealtime=true — Prevents attempts to enable realtime scheduling.
 - RestrictSUIDSGID=true — Prevents executing setuid or setgid binaries.
 - RestrictAddressFamilies=AF_INET — Restricts the usable socket address families to IPv4 only (AF_INET).
 - RestrictNamespaces=true — Prevents creating any new namespaces.
 - SystemCallFilter=... — Restricts the allowed syscalls to the absolute minimum. If you aren't willing to maintain your own custom seccomp filter, then systemd provides many predefined system call sets that you can use. @system-service will be suitable for many use cases.
 - SystemCallArchitectures=native — Prevents executing syscalls from other CPU architectures.
 - UMask=0077 — Sets the umask to a more restrictive value.
 - IPAddressDeny=any — Blocks all incoming and outgoing traffic to/from any IP address. Set IPAddressAllow= to configure a whitelist. Alternatively, setup a network namespace with PrivateNetwork=true.
 - AppArmorProfile=... — Runs the process under the specified AppArmor profile.

TODO: AppArmor/SELinux profile for the beacon chain and validator apps

## Firewall considerations (Thank you ArchWiki and Samuel! )
#### Please read before copy-pasta something... you will LOCK YOURSELF OUT from your server!!!
--https://wiki.archlinux.org/index.php/Simple_stateful_firewall

--https://blog.samuel.domains/blog/security/nftables-hardening-rules-and-good-practices

nftables is a netfilter project that aims to replace the existing {ip,ip6,arp,eb}tables framework. It provides a new packet filtering framework, a new user-space utility (nft), and a compatibility layer for {ip,ip6}tables. It uses the existing hooks, connection tracking system, user-space queueing component, and logging subsystem of netfilter.

Firewalld or SuseFirewall2 - because in general this can only be encountered in - are just pure frontenda which comes with Red Hat/openSUSE. They are not an independent firewall by themself. They only operates by taking instructions, then turning them into nftables rules (formerly iptables), and the nftables rules ARE the firewall. So I have a choice between running "firewalld using nftables" or running "nftables only". Let's use nftables only! Much more simle!

(Note: openSUSE Leap 15.0 introduces firewalld as the new default software firewall, replacing SuSEfirewall2. SuSEfirewall2 has not been removed from openSUSE Leap 15.0 and is still part of the main repository, though not installed by default.)

You should always block all incoming traffic unless you have a specific reason not to. It is recommended to set up a strict firewall. Firewalls must be fine-tuned for your system, and there is not one ruleset that can fit all of them. Also you must understand the netfilter flow, so your firewall rules could be effective, and can work properly. Reference: neftilter flow: https://wiki.nftables.org/wiki-nftables/index.php/Netfilter_hooks#Priority_within_hook

First we create the skeleton. It's important to use the right order!

```
# Flush any current ruleset
nft flush ruleset
```

To mitigate DDoS attacks and script kiddies exploration define a new table, with a netdev network family type.
By setting priority lower than NF_IP_PRI_CONNTRACK_DEFRAG (= -400), we are sure that our chain will be evaluated before any other one registered on the ingress hook. This makes it the perfect place to set our DDoS counter-measures, as we would "spare" a few CPU cycles per packet.
For some reason the interface name must be hardcoded here (eth0), variable do not work!
!IMPORTANT: escape any special character/expression, like & or ;

```
# Add netdev type table and a chain
nft add table netdev filter
nft add chain netdev filter ingress '{type filter hook ingress device eth0 priority -500;}'

# Drop all fragments.
nft add rule netdev filter ingress 'ip frag-off & 0x1fff != 0 counter drop'

# Drop XMAS packets.
nft add rule netdev filter ingress 'tcp flags & (fin|syn|rst|psh|ack|urg) == fin|syn|rst|psh|ack|urg counter drop'

# Drop NULL packets.
nft add rule netdev filter ingress 'tcp flags & (fin|syn|rst|psh|ack|urg) == 0x0 counter drop'

# Drop uncommon MSS values.
nft add rule netdev filter ingress 'tcp flags syn tcp option maxseg size 1-535 counter drop'

# Drop bogons (on your home lab, this WILL LOCK YOU OUT! Remove your home network from the above list!)
# If you use 192.168.1.0/24 remove the associated "192.168.0.0/16" rule
nft add rule netdev filter ingress 'ip saddr { 0.0.0.0/8,10.0.0.0/8,100.64.0.0/10,127.0.0.0/8,169.254.0.0/16,172.16.0.0/12,192.0.0.0/24,192.0.2.0/24,192.168.0.0/16,198.18.0.0/15,198.51.100.0/24,203.0.113.0/24,224.0.0.0/3 } counter drop'

```

Add a table and add the input, forward, and output base chains. The default policy for input and forward will be to drop. The policy for output will be to accept. Describing an inet table allows us to handle any IPv4 (ip) and IPv6 (ip6) packets at the very same location (even if don't use ipv6, one day we may will use it)!
```
# Add a table. This will contain the main firewall chains and rules
nft add table inet my_table

# Add the default chains and policy.
nft add chain inet my_table input '{ type filter hook input priority 0 ; policy drop ; }'  <--- this will lock you out!!!! Change policy to accept if you do this from a remote machine and modify later, when all other rules are set!
nft add chain inet my_table forward '{ type filter hook forward priority 0 ; policy drop ; }'
nft add chain inet my_table output '{ type filter hook output priority 0 ; policy accept ; }'
```

Add two regular chains that will be associated with tcp and udp rules
```
nft add chain inet my_table tcp_chain
nft add chain inet my_table udp_chain
```

In order to match "new" packets, we need the help of the conntrack Netfilter module.
The problem : It’s not available within a chain registered with the ingress or my_table input hook, that’s why we gotta use it elsewhere: the PREROUTING chain of the filter table, at the mangle (-150) priority.
```
nft add table inet mangle
nft add chain inet mangle prerouting '{type filter hook prerouting priority -150;}'

# drop any packet flagged as invalid by the conntrack module
nft add rule inet mangle prerouting ct state invalid counter drop

# drop any new packet, presenting any other TCP flag beside SYN
nft add rule inet mangle prerouting 'tcp flags & (fin|syn|rst|ack) != syn ct state new counter drop'
```

The skeleton is ready. We have dropped a lot of fishy traffic and defined the place where we can start to accept incoming connections.

```
# Related and established traffic will be accepted
nft add rule inet my_table input ct state related,established accept

# All loopback interface traffic will be accepted
nft add rule inet my_table input iif lo accept

# Allow but rate limit icmp-echo requests
nft add rule inet my_table input icmp type echo-request limit rate 1/second burst 5 packets accept

# New udp traffic will jump to the UDP chain
nft add rule inet my_table input meta l4proto udp ct state new jump udp_chain

# New tcp traffic will jump to the TCP chain
nft add rule inet my_table input 'meta l4proto tcp tcp flags & (fin|syn|rst|ack) == syn ct state new jump tcp_chain'

# Reject all traffic that was not processed by other rules
nft add rule inet my_table input meta l4proto udp drop
nft add rule inet my_table input meta l4proto tcp reject with tcp reset
nft add rule inet my_table input counter reject with icmpx type port-unreachable

```
At this point you should decide what ports you want to open to incoming connections, which are handled by the TCP and UDP chains. For example to open connections for ssh:
(REMEMBER: use your own ssh port!!!!)

```
# Allow ssh
nft add rule inet my_table tcp_chain tcp dport 2992 counter limit rate 4/second accept
```
Save the firewall config
```
# nft list ruleset > /etc/sysconfig/nftables.conf
```

To use native nftables, disable and mask the firewalld/iptables service.
```
systemctl disable firewalld
systemctl mask --now firewalld
systemctl enable nftables
```

If nftables is isntalled but there is no systemd service for it, you have to create one at /etc/systemd/system/nftables.service 
```
[Unit]
Description=Netfilter Tables
Documentation=man:nft(8)
Wants=network-pre.target
Before=network-pre.target

[Service]
Type=oneshot
ProtectSystem=full
ProtectHome=true
ExecStart=/usr/sbin/nft -f /etc/sysconfig/nftables.conf
ExecReload=/usr/sbin/nft 'flush ruleset; include "/etc/sysconfig/nftables.conf";'
ExecStop=/usr/sbin/nft flush ruleset
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target

```

If you did this from a remote machine, now it's safe to change the default input policy to drop.
Edit the file /etc/sysconfig/nftables.conf and change
```
table inet my_table {
        chain input {
                type filter hook input priority filter; policy accept;

```

to:
```
table inet my_table {
        chain input {
                type filter hook input priority filter; policy drop;

```

And reload the rule set:
```
systemctl reload nftables
```

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
nftables_family = inet
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
