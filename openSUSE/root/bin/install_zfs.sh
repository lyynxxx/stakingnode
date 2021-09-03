#!/bin/bash
mount -o remount,exec /var
mount -o remount,rw /usr
mount -o remount,rw /boot
zypper ar https://download.opensuse.org/repositories/filesystems/openSUSE_Leap_15.2/filesystems.repo
zypper -n ref 
zypper -n in zfs 
