#!/bin/bash
# Set immutable options for password files, to prevent modification or accidental deletion (this will fluff you too! :D )

chattr +i /etc/passwd
chattr +i /etc/shadow
#chattr +i /etc/fstab


rm -rf /tmp/kickstart
rm -rf /opt/tmp/*
