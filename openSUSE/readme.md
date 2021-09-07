# Autoyast Installation of openSuSE Leap 15.2
##### Please read before fluffing up your already working system or jumping into anything!!! Also feel free to correct me, if you know better ways, I'm always happy to learn new things (mailto: lyynxxx@gmail.com).

A regular installation of openSUSE Leap is semi-automated by default. The user is prompted to select the necessary information at the beginning of the installation (usually language only). YaST then generates a proposal for the underlying system depending on different factors and system parameters. Usually - and especially for new systems - such a proposal can be used to install the system and provides a usable installation. The steps following the proposal are fully automated.

AutoYaST can be used where no user intervention is required or where customization is required. Using an AutoYaST control file, YaST prepares the system for a custom installation and does not interact with the user, unless specified in the file controlling the installation.

AutoYaST is not an automated GUI system. This means that usually many screens will be skipped - you will never see the language selection interface, for example. AutoYaST will simply pass the language parameter to the sub-system without displaying any language related interface.

Using AutoYaST I can spin up a new system faster, if I need a new validator or I have to rebuild my validator in a new environment, maybe with an other client.

Download installer: [openSUSE Leap 15.2 Network Installer](http://download.opensuse.org/distribution/leap/15.2/iso/openSUSE-Leap-15.2-NET-x86_64.iso)


## So... How to start???
Assuming, you made it this far and mostly know what we will do...

You need a HTTP server, from where the installer can download the AutoYaST control file. You can use your phone at home if it's on the same network as your validator machine. Or you can pack into the iso too.

At home, I just downloaded the [latest stable nginx for windows](http://nginx.org/download/nginx-1.18.0.zip), extracted the files, and copyed my scripts and AutYaST files into the "html" folder.

 - If you plan to do this at home: get a PC with the neccesary hardware resources, download the openSUSE boot image I linked at the beginning, and boot (you can use Rufus to create bootable USB media or use your phone and DriveDroid). In the boot menu select the "Install" with the arrow keys (don't press enter!) and start (typing) adding boot parameters: "autoyast=http://YOURHTTPSREVER/autoyastfile.xml" and press enter. Assuming you have DHCP at home, the installer will get network and will be able to download the ks file and set up the system.

  - If you want to install some hosted machine or remote virtual machine and have DHCP the steps are the same, only you need VNC or some kind of console access. In case you have no access to DHCP, but you have an allocated, fix IP, you must set up the network in the boot kernel parameters, right after the autoyast file. The format:
```
ifcfg=INTERFACE="IPS_NETMASK,GATEWAYS,NAMESERVERS,DOMAINS(this one is)"
for example (* as INTERFACE means whatewer network interface is plugged in)
ifcfg=*="192.168.10.92/24,192.168.10.1,8.8.8.8"
```
![]( https://gitlab.com/lyynxxx/stakingnode/-/blob/master/openSUSE/autoyast/img/autoyast01.PNG )
You may want to use a PC and put the node in VirtualBox/VMware/HyperV/KVM/Xen/something, so after you set up everything you can create a full VM backup and move it to a NAS or some safe place and you don't have ot wait another two days to geth full sync if you have to restore the VM.
In this case if you run Win10 as the host operating system, you definetly want to disable auto updates and auto restarts...


## Customizing the AutoYaST control file and the scripts
The control file is in the "autoyast" directory with the scipts it can call during the installation process. The control file and all the scripts must be available by the VM/machine you try to spin up. The simplest way to do this at home, to download Nginx and start it on your main PC, just as mentinoed above.

You need to change a few things, before you can use the control file:
 - timezone
 - hostname
 - your networking: nameserver, ipaddr, network, gateway, interface name maybe, etc. 
 - user_password for the root user
 - username for your own user, who can log in
 - authorized_keys for your own user, who can log in. You can't miss this, as by default only ssh-key based authentication is allowed!
 - lastly post-scripts, what scrpits to call, to extend the base OS installation.
 - add your own scripts

About the secondary scripts:
 - 01.hardening.sh: This script contains post-installation settings. It changes the default configs and copy new ones from this git repo into the system, like firewall rules, sysctl tunes, audit rules, cron jobs, fine tune fstab settings, etc. The script contains comments, so you can see what the commands are doing. As a validator you should have some trust issues!!!! As IvanOnTech says, don't trust, validate! Don't copy-paste or use the files as is!
 - 02.adduseres.sh: This script contains the Validator user creation, binary download, config and validator init steps. Also creates a script into the "root" user home, to update the external address for p2p connections if the home users router restarts and get a new IP.
 - 011.hardening.sh: locks down /etc/passwd and /etc/shadow with immutable flags :) Noone can create new users or change passwords!!!
 