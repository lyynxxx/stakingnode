#!/bin/bash
# Set immutable options for password files, to prevent modification or accidental deletion (this will fluff you too! :D )

chattr +i /etc/passwd
chattr +i /etc/shadow

rm -rf /tmp/kickstart
rm -rf /opt/tmp/*
