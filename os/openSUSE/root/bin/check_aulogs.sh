#!/bin/bash

ALERT=/root/bin/audit_alert.txt
LOGFILE=/root/bin/audit.log
TEXTFILE_COLLECTOR_DIR=/opt/node_exporter


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
                    echo "Only some ips banned... not spamming mailbox, but activity logged..." >> $LOGFILE
                else
                    echo "Sending mail..." >> $LOGFILE
                    set_mail=TRUE
                fi

        fi

done

echo "Creating tmp file for Prometheus metrc to check audisp is sending auditd logs..."
umask 222
touch "$TEXTFILE_COLLECTOR_DIR/auditd_textfcollector.prom.$$"
echo "##Check is remote server getting logs. 0=no 1=yes, Prometheus will send alert if 0" > $TEXTFILE_COLLECTOR_DIR/auditd_textfcollector.prom.$$

## update texfile collector
ISTHISEMPTY=$(ausearch --node eth.vm -ts recent)
if [ -z "$ISTHISEMPTY" ]; then 
        # the variable is empty, which means the remote node not sending logs here, write "0" as metric to Prometheus
        echo "audisp_got_recent_logs    0" >> $TEXTFILE_COLLECTOR_DIR/auditd_textfcollector.prom.$$
else
        # the variable is not empty, which means the remote node is sending logs here, write "1" as metric to Prometheus
        echo "audisp_got_recent_logs    1" >> $TEXTFILE_COLLECTOR_DIR/auditd_textfcollector.prom.$$
fi
mv "$TEXTFILE_COLLECTOR_DIR/auditd_textfcollector.prom.$$" "$TEXTFILE_COLLECTOR_DIR/auditd_textfcollector.prom"


## if file is not empty, send mail
if  [ "$set_mail" = "TRUE" ]; then
    echo "Alerts included..."
    echo "some Fckery Detected! Sending mail with alerts..." >> $LOGFILE
    cat $ALERT | /usr/bin/mailx -s 'Some Fckery Detected on your StakingNode(CENTRAL)' lyynxxx@gmail.com
fi
