# Installation of openSuSE Leap 15.3
##### Please read carefully before you would jump into anything directly or even break an already working system!!! Also feel free to correct me if you know better ways, I'm always happy to learn new things (mailto: lyynxxx@gmail.com).

A regular installation of openSUSE Leap is semi-automated by default. The user is prompted to select the necessary information at the beginning of the installation (usually language only). YaST then generates a proposal for the underlying system depending on different factors and system parameters. Usually - and especially for new systems - such proposal can be used to install the system. The steps following the proposal are fully automated.

AutoYaST can be used where no user intervention is required or where customization is required. Using an AutoYaST control file, YaST prepares the system for a custom installation and does not interact with the user, unless it is specified in the file that controls the installation.

AutoYaST is not an automated GUI system. This means that usually many screens will be skipped – e.g.: you will never see the language selection interface. AutoYaST will simply pass the language parameter to the sub-system without displaying any language-related interface.

Using AutoYaST I can spin up a new system faster, if I need a new validator or I have to rebuild my validator in a new environment, maybe with a different client.

Download installer: [openSUSE Leap 15.3 Network Installer from the official site](https://get.opensuse.org/leap/15.3/)
I prefer to use the Network Installer, but you can use the offline image too.

## So... How to start???
Assuming, you made this far and mostly know what we are going to do, first I will show you a simple, manual installation of SUSE and after that I will show how to use the automated setup.

### Manual installation
Download the ISO and boot your machine. This is the first screen you can see. As this is an installation, chose the second option "Installation" from the menu.

![img 1](img/01-bios.PNG?raw=true)

The ISO will check your system, load all the basic drivers and try to start the installer GUI.

![img 2](img/02.PNG?raw=true)
![img 3](img/03.PNG?raw=true)

The installer will try to configure network with DHCP. Mostly this will be fine for you as a home validator. If you don't have DHCP you must use full DVD ISO or define networking before starting the process. (Details in: AutoYast installation section) 

![img 4](img/04.PNG?raw=true)

The first settings, where the installer waits some feedback are the Language settings and the License agreement.

![img 5](img/05.PNG?raw=true)

If there is newtork, the installer will try to refresh de default repositories. Allow it.

![img 6](img/06.PNG?raw=true)

Accept the defaults. These are good enough, we will update them later from the post-install scripts.

![img 7](img/07.PNG?raw=true)

The installer will update the repositories which will be used.

![img 8](img/08.PNG?raw=true)

System roles are predefined use cases. We want minimal packeges only, just like a server. This won't install any GUI or extra utility. (for example no ping command)

![img 9](img/09.PNG?raw=true)

Partitioning... the first dark forest. Some may fear this... :)
I do NOT recommend the defaults. As I wrote earlier, I have my own partition layout designed, let's use that.
First we tell the installer we want to user the "Expert Partitioner" mode, we can start with the current proposal.

![img 10](img/10.PNG?raw=true)

This is the default proposal. First we need to clean up.

![img 11](img/11.PNG?raw=true)

The default proposal uses Btrfs for system partitions, while it could work, I prefer XFS and LVM.
Select the partition that contains the Btrfs filesystem on the left panel, and the filesystem on the right, then click on the "Delete" button on the bottom.

Now that Btrfs subvolumes are purged, also delete all remaining partitions.

![img 12](img/12.PNG?raw=true)

Delete all the partitions, we will re-create what we need.

![img 13](img/13.PNG?raw=true)

With a clean disk, where no partition exsist any more, click on the "Add Partitoin" button. We will create three partition.
First, we need a partition with type "BIOS Boot Partition". This will contain some data required to boot the system.

![img 14](img/14.PNG?raw=true)

This partition will be small, only 8M. Leave the geomatry settings default. Newer systems will allign partitions by default to match the disk geometry.

![img 15](img/15.PNG?raw=true)

The Role is not important here. Basically if you select "Operating system" the GUI will propose to use Btrfs filesystem and if you select "Data nad ISV" the default filesystem is XFS. This is what we need, but if you select "Operating system" we still can change it.

For now, as the first partition is the BIOS Boot Partition, select this from the dropdown menu.

![img 16](img/16.PNG?raw=true)

This will be the screen, after you first partition created.

![img 17](img/17.PNG?raw=true)

Now add another partition. The size should be 256M (or 512M if you want to keep more kernel version.)

![img 18](img/18.PNG?raw=true)
The partition type should be XFS, also select the mount point, which is "/boot".

The third partition we need is a partition for the Logical Volume Group. LVM can help us to magage partition sizes dinamically.
We don't want to format this partition or assign any geomatry. Just select "RAW volume"

![img 19](img/19.PNG?raw=true)

Important to check the Partition ID: Linux LVM.

![img 20](img/20.PNG?raw=true)

This is the partition layout at the moment.

![img 21](img/21.PNG?raw=true)

Let's start to create the volumes. Select the "LVM Volume Groups" on the left and click on the "Add Volume Group" button.

![img 22](img/22.PNG?raw=true)

Name the volume group. Select the largest partition, this is where the volumes will be hosted, and add to the selected devices list.

![img 23](img/23.PNG?raw=true)

After the volume group is created we can create the logical volumes. The button is now visible.

![img 24](img/24.PNG?raw=true)

Click on the button "Add Logical Volume..."

From now on the steps will repeat. First we name the new logical volume.

![img 25](img/25.PNG?raw=true)

Add a custom size. Just as we planned. For example if the first partition is the "root", 3G is more then enough.

![img 26](img/26.PNG?raw=true)

Select the role "Data and ISV". Change the mount options. You can also type into the dropdown menu, not just select what is available there.

![img 29](img/29.PNG?raw=true)

And now you can see your first logical volume.

![img 30](img/30.PNG?raw=true)

Repeat these steps to create all the other partitions as logical volumes (/var, /usr, /tmp, swap and /opt). To create swap, the Role must be "swap"

![img 31](img/31.PNG?raw=true)

![img 32](img/32.PNG?raw=true)

Your final layout will look like this.
![img 33](img/33.PNG?raw=true)

The defaults are not prepared for this kind of minimal setup, so the system will alert you, that the root is not even 5G. You can ignore the warning.

![img 34](img/34.PNG?raw=true)

Click "Yes" to continue...

A summary will show up.

![img 35](img/35.PNG?raw=true)

Select your timezone.

![img 36](img/36.PNG?raw=true)

Create a user. This is the only user we will use to log in. No other users will have shell access.
An important setting is "Use this password for system administration". Basically this means this will be your root password too. I don't recommend this!

![img 37](img/37.PNG?raw=true)

You may want to set static IP address. You can do this from the summary screen. Select "Network settings" link. Or just click "Install" if DHCP is fine.

![img 39](img/39.PNG?raw=true)

If you don't want DHCP/or want DHCP just not IPv6 select the network card you want to configure and click on "Edit" button.

![img 40](img/40.PNG?raw=true)

We don't really use IPv6, so better to disable it!

![img 41](img/41.PNG?raw=true)

Select "Statically Assigned IP Address" to set the IP manually. 

![img 42](img/42.PNG?raw=true)
Set your IP, netmask and hostname and "Next".

Select the Hostname/DNS tab.

![img 43](img/43.PNG?raw=true)

This is where you must specify your DNS servers.

![img 44](img/44.PNG?raw=true)

And finally we need to add the defaults route. Select the "Routing" tab.

![img 45](img/45.PNG?raw=true)

Click "Add"

Define your default route. The IP of your router and the network device you use. Mostly there will be only one.

![img 46](img/46.PNG?raw=true)

After this click "Next" and the installer will change the settings.

![img 48](img/48.PNG?raw=true)

Click Install to start the process.

![img 49](img/49.PNG?raw=true)

Confirm. From now on the installer will create the partitions, download and install the packages, etc.

![img 50](img/50.PNG?raw=true)

The progress screen will show you what tasks the installer is doing.

![img 51](img/51.PNG?raw=true)

After everything is finished, the system will reboot.

![img 53](img/53.PNG?raw=true)

From now on you can log in to the machine with your user. 

![img 55](img/55.PNG?raw=true)


### AutoYast installation
I think it is worth your time to create the all the resources you need to do an automated installation...

You need a HTTP server, from where the installer can download the AutoYaST control file. You can use your phone at home if it's on the same network as your validator machine,or you can pack the files into the iso too.

At home, I just download the [latest stable nginx for windows](https://nginx.org/en/download.html), extract the files, and copy my scripts and AutYaST files into the "html" folder.

 - If you plan to do this at home: get a PC with the necessary hardware resources, download the openSUSE boot image I linked at the beginning and boot (you can use Rufus to create bootable USB media or use your phone and DriveDroid). In the boot menu select the "Install" with the arrow keys (don't press enter!) and start adding (by typing the) boot parameters: "autoyast=http://YOURHTTPSREVER/autoyastfile.xml" then press enter. Assuming you have DHCP at home, the installer will get network and will be able to download the ks file and set up the system.

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
