#!/bin/bash
# runs on remote auditd vm every 10 min

ALERT=/root/bin/audit_alert.txt
LOGFILE=/root/bin/audit.log
if ! [ -f $SEM ]; then
        echo "Creating logfile..."
        echo "-------------------------" > $LOGFILE
        echo "" >> $LOGFILE
        date >> $LOGFILE
else
        echo "Updateding logfile..."
        echo "-------------------------" >> $LOGFILE
        echo "" >> $LOGFILE
        date >> $LOGFILE
fi

## Auditd keys to check
CHECK_KEYS=( "sshd" "identity" "susp_activity" "sbin_susp" "perm_mod" "file_modification" "file_access" "unauthedfileaccess" "priv_esc" "perm_mod" "vkeys")
echo > $ALERT
set_mail=FALSE

for i in ${CHECK_KEYS[@]};do
        echo "Check recent audit logs for key: $i"

        RESULT=$(ausearch --node eth.vm -ts recent -k $i)
        if [ -z "$RESULT" ]; then
                echo "No result... all fine!"
                echo "ausearch --node eth.vm -ts recent -k $i" >> $LOGFILE
                echo "No result... all fine!" >> $LOGFILE
                echo " " >> $LOGFILE

        else
                echo "SOME FUCKERY DTECTED WITH KEY: $i"
                echo "SOME FUCKERY DTECTED WITH KEY: $i" >> $ALERT
                ausearch --node eth.vm -ts recent -k $i >> $ALERT
                echo " " >> $ALERT

                echo "SOME FUCKERY DTECTED WITH KEY: $i" >> $LOGFILE
                ausearch --node eth.vm -ts recent -k $i >> $LOGFILE
                echo " " >> $LOGFILE

                FWBANNSPAM=$(grep "EXECVE" audit_alert.txt | grep -v "nft")
                if [ -z $FWBANNSPAM ]; then
                    echo "Only some ips banned... not spamming mailbox, but logged activity..."
                else
                    echo "Sending mail..."
                    set_mail=TRUE
                fi

        fi

done

## if file is not empty, send mail
if  [ "$set_mail" = "TRUE" ]; then
    echo "Alerts included..."
    echo "some Fckery Detected! Sending mail with alerts..." >> $LOGFILE
    cat $ALERT | /usr/bin/mailx -s 'Some Fckery Detected on your StakingNode(CENTRAL)' lyynxxx@gmail.com
fi
