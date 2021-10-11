## So, let's build a validator for ETH 
What do we need?

	-	Install a new operatnig system. Only with minimal package set, no GUI, Geth and the preferred ETH2 clients including the module files in the AutoYast control file. Geth will start at boot time.
	-	Download the eth2.0-deposit-cli. I do not include this into the scripts. DO THIS ON YOUR OWN! Douple check, you are downloading the original!(https://github.com/ethereum/eth2.0-deposit-cli). You can do this in a separate machine.
	-	Signup to be a validator at the Launchpad
	-	Configure and sync ETH2 beacon chain client
	-	Configure and start ETH2 validator client
	-	Create a separate monitoring stack

## Installing the new system, step-by-step

#### Download the files above from this repo

 - openSUSE/autoyast/autoyast.xml
 - openSUSE/autoyast/stage2/01-system-setup.sh
 - openSUSE/autoyast/stage2/99-lockdown.sh
 - modules/service-geth.sh
 - modules/service-prysm.sh
 - modules/service-netdata.sh

#### autoyast.xml

This control file contains all the parameters to set up the operating system, like: netwok settings, packege list, user to create, post install scripts.
Open the file with notepad++, sublime or your preferred text editor. Please keep in mind, the files must use UTF8 charset and Unix line ending format!
Change:

line 139: hostname
line 138: domain

line 141: firsd DNS server address
line 142: second DNS server address (this is google DNS, you can leave it too)

line 150: IP address of your node
line 151: the subnet mask of your node (if you need to change... it's most likely /24, so you may can leave this)
line 152: the network
line 153: the netmask prefix (same as line 151)

line 164: your default gateway (your router's IP)

line 238: the root users password

line 242: your username
line 243: your users password
line 246: include your ssh public key! ONYL KEY BASED LOGIN IS ALLOWED!!!! 

line 254 and more: the post install scripts. By default onyl two are included. Include as many new <script> block as many you want, like service-geth.sh, service-prysm.sh and service-netdata.sh.

Check the line endings!
Copy the file into the "html" folder.

#### 01-system-setup.sh
This file contains some hardening setps and the commands to clone this repo, donwload all the firewall settings, system audit settings, kernel parameter tunings, etc. It will enable the firewall and the auditing daemon to start at boot time.

#### 99-lockdown.sh
This file will lock the ability to create new users or change passwords. Not even root will be able to change passwords after the first reboot!

#### service-geth.sh
This file contains the steps to install Geth to the new machine.
The commands used here will create a service user, create folders, download Geth, change folder permissions and download the service file.

#### service-prysm.sh
This file contains the steps to install Prysm to the new machine.
The commands used here will create a service user, create folders, download Geth, change folder permissions and download the service file.
The beacon chain client and the validator client will have separate service users.

