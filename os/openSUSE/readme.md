# Autoyast Installation of openSuSE Leap 15.3
##### Please read carefully before you would jump into anything directly or even break an already working system!!! Also feel free to correct me if you know better ways, I'm always happy to learn new things (mailto: lyynxxx@gmail.com).

A regular installation of openSUSE Leap is semi-automated by default. The user is prompted to select the necessary information at the beginning of the installation (usually language only). YaST then generates a proposal for the underlying system depending on different factors and system parameters. Usually - and especially for new systems - such proposal can be used to install the system. The steps following the proposal are fully automated.

AutoYaST can be used where no user intervention is required or where customization is required. Using an AutoYaST control file, YaST prepares the system for a custom installation and does not interact with the user, unless it is specified in the file that controls the installation.

AutoYaST is not an automated GUI system. This means that usually many screens will be skipped – e.g.: you will never see the language selection interface. AutoYaST will simply pass the language parameter to the sub-system without displaying any language-related interface.

Using AutoYaST I can spin up a new system faster, if I need a new validator or I have to rebuild my validator in a new environment, maybe with a different client.

Download installer: [openSUSE Leap 15.3 Network Installer](https://download.opensuse.org/distribution/leap/15.3/iso/openSUSE-Leap-15.3-NET-x86_64-Media.iso)


## So... How to start???
Assuming, you made this far and mostly know what we are going to do...
First I will show you a simple, manual installation of SUSE and after that I will show how to use the automated setup.

## Manual installation
Download the ISO and boot your machine. This is the first screen you can see. As this is an installation, chose the second option "Installation"

![img 1](img/01-bios.PNG?raw=true)

The ISO will check your system, load all the basic drivers and try to start the installer GUI.
![img 2](img/02.PNG?raw=true)
![img 3](img/03.PNG?raw=true)

The installer will try to configure network with DHCP. Mostly this will be fine for you as a home validator.
![img 4](img/04.PNG?raw=true)

The first settings, where the installer waits some feedback are the Language settings and the License agreement.
![img 5](img/05.PNG?raw=true)

If there is newtork, the installer will try to refresh de default repositories. Allow it.
![img 6](img/06.PNG?raw=true)

Accept the defaults.
![img 7](img/07.PNG?raw=true)

The installer will update the repositories which will be used.
![img 8](img/08.PNG?raw=true)

System roles are predefined use cases. We want minimal packeges only, just like a server. This won't install any GUI!!!
![img 9](img/09.PNG?raw=true)

Partitioning... the first dark forest. Some may fear this... :)
I do NOT recommend the defaults. As I wrote earlier, I have my own partition layout designed, let's use that.
First we tell the installer we want to user the "Expert Partitioner" mode, we can start with the current proposal.
![img 10](img/10.PNG?raw=true)




## AutoYast installation

You need a HTTP server, from where the installer can download the AutoYaST control file. You can use your phone at home if it's on the same network as your validator machine,or you can pack the files into the iso too.

At home, I just downloaded the [latest stable nginx for windows](https://nginx.org/en/download.html), extracted the files, and copied my scripts and AutYaST files into the "html" folder.

 - If you plan to do this at home: get a PC with the necessary hardware resources, download the openSUSE boot image I linked at the beginning and boot (you can use Rufus to create bootable USB media or use your phone and DriveDroid). In the boot menu select the "Install" with the arrow keys (don't press enter!) and start  adding (by typing the) boot parameters: "autoyast=http://YOURHTTPSREVER/autoyastfile.xml" then press enter. Assuming you have DHCP at home, the installer will get network and will be able to download the ks file and set up the system.

  - If you want to install some hosted machine or remote virtual machine and have DHCP, the steps are the same - you only need VNC or some kind of console access. In case you have no access to DHCP but you have an allocated, fix IP, then you must set up the network in the boot kernel parameters, right after the autoyast file. The format:
```
ifcfg=INTERFACE="IPS_NETMASK,GATEWAYS,NAMESERVERS,DOMAINS(this one is)"
for example (* as INTERFACE means whatewer network interface is plugged in)
ifcfg=*="192.168.10.92/24,192.168.10.1,8.8.8.8"
```
[Check the screenshots of an installation here...](https://gitlab.com/lyynxxx/stakingnode/-/blob/master/openSUSE/autoyast/img/)

You may want to use a PC and put the node in VirtualBox/VMware/HyperV/KVM/Xen/something, so after you set up everything you can create a full VM backup and move it to a NAS (or some safe place) and you don't have to wait another two days to get full sync if you have to restore the VM.
In this case if you run Win10 as the host operating system, you definetly want to disable auto updates and auto restarts...

## Customizing the AutoYaST control file and the scripts
The control file is in the "autoyast" directory with the scipts it can call during the installation process. The control file and all the scripts must be available by the VM/machine you try to spin up. The simplest way to do this at home is to download Nginx and start it on your main PC, just as mentinoned above.

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
 - 01-system-setup.sh: This script contains post-installation settings. It changes the default configs, download and copy new ones from this git repo into the system, like firewall rules, sysctl tunes, audit rules, cron jobs, finetune fstab settings, etc. The script contains comments, so you can see what the commands are for. As a validator you should have some trust issues!!!! Don't copy-paste or use the files as they are!
 - 99-lockdown.sh: locks down /etc/passwd and /etc/shadow with immutable flags :) No one can create new users or change passwords!!!

Modules:
I try to speparate the base OS and all the things it will run. The autoyast control file contains the bare minimum for the system to run. The "system setup" script only downloads the general system configuration which is needed on every system, like system tunables, firewall rules, audit rules. All the other services like the Prysm Beacon chain, Prometheus, Netdata, etc. has their own bash shall file, which creates the service users, downloads binaries and settings...

You can add them one-by-one to the end of the autoyast control file. In this way I have a modular auto installer. Like lego bricks, I can create different systems. The shell scripts can be runned after the system setup if you may forgot something. These are standard bash/linux cli commands, nothing fancy.

For example I need to create a new OS but only for grafana, then I have to modify the autoyast control file this way:
```
<scripts>
	<post-scripts config:type="list">
		<script>
			<location>http://192.168.10.125/vm/01-system-setup.sh</location>
		</script>
		<script>
			<location>http://192.168.10.125/vm/service-grafana.sh</location>
		</script>
		<script>
			<location>http://192.168.10.125/vm/99-lockdown.sh</location>
		</script>
	</post-scripts>
</scripts>
```

After stage2 openSUSE starts most of the services, but as fstab options change and some other settings requires reboot(right after the setup is finished),it is recommended to restart the machine.
