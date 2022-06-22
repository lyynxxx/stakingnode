# Installation of Red Hat 8.6

The [Red Hat Developer Subscription for Individuals](https://developers.redhat.com/articles/faqs-no-cost-red-hat-enterprise-linux) is a no-cost offering of the Red Hat Developer program and includes access to Red Hat Enterprise Linux among other Red Hat products. It is a program and an offering designed for individual developers, available through the Red Hat Developer program.

Users can access this no-cost subscription by joining the Red Hat Developer program at [developers.redhat.com/register](https://developers.redhat.com/register/). Joining the program is free and is needed if you want to download the installer ISO and want to get updates.

The use cases for Red Hat Enterprise Linux have been expanded in the Red Hat Developer Subscription for Individuals. The Red Hat Developer Subscription for Individuals is a single subscription, which allows the user to install Red Hat Enterprise Linux on a maximum of 16 systems, physical or virtual, regardless of system facts and size. Those 16 nodes may be used by the individual developer for demos, prototyping, QA, small production uses, and cloud access.

Download one of the installer ISOs:
 - Red Hat Enterprise Linux 8.6 Boot ISO
 - Red Hat Enterprise Linux 8.6 Binary DVD (recommended)

## So... How to start???
Assuming, you made this far and mostly know what we are going to do, first I will show you a simple, manual installation of RHEL8 and after that I will show how to use the automated setup.

### Manual installation (WIP)
Download the ISO and boot your machine. This is the first screen you can see. As this is an installation, chose the second option "Install Red Hat Enterprise Linux 8.6" from the menu. The second menu entry is the default, the media test! The color schema is not the best, keep in mind, you have to move up one line to start the installation!

![img 1](img/01.PNG?raw=true)

The ISO will check your system, load all the basic drivers and try to start the installer GUI.

![img 2](img/02.PNG?raw=true)
![img 3](img/03.PNG?raw=true)

The first screen of the installer is the language selection.

![img 4](img/04.PNG?raw=true)

Click the button "Continue".

On the installation summary screen you can check the most important settings.
Depending which ISO you use you may see different settings. For examlple, using the full dvd you don't have to setup an installation source, the source will be the local media.

![img 5](img/05-boot.PNG?raw=true)

To use the Red Hat CDN to install your system (using to boot ISO), you must have an active subscription and you must connect to Red Hat first before any other step.

![img 5](img/05-dvd.PNG?raw=true)

If you use the full dvd, your only mandatory setting is to chose the destination drive and setup partitions. The full dvd ISO is  recommended, as during the installation you don't have to worry about your subscription, RHN, etc. If you missconfigure your partitions, you can start over and don't have to clean up your registered systems on the Red Hat Customer Portal as the installation itself won't register the system, you must register it after the installation.



