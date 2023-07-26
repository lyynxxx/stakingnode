## Autoinstall
The server installer for 20.04 supports a new mode of operation: automated installation, autoinstallation for short. You might also know this feature as unattended or handsoff or preseeded installation.

Autoinstallation lets you answer all those configuration questions ahead of time with an autoinstall config and lets the installation process run without any interaction.

The autoinstall config is provided via cloud-init configuration, which is almost endlessly flexible. In most scenarios the easiest way will be to provide user-data via the nocloud data source.

Introduction: https://ubuntu.com/server/docs/install/autoinstall
Reference: https://ubuntu.com/server/docs/install/autoinstall-reference

## Create custom ISO for configs:
https://dustinspecker.com/posts/ubuntu-autoinstallation-virtualbox/


autoinstall ds=nocloud-net;s=http://_gateway:3003/
autoinstall cloud-config-url=http://192.168.0.2/autoinstall.yaml 
https://www.molnar-peter.hu/en/ubuntu-jammy-netinstall-pxe.html