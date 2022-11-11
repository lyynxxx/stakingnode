#!/bin/bash

SEM=/root/check.sem
LOG=/root/audit_alert.txt

if ! [ -f $SEM ]; then
	echo "Creating semaphore file..."
	date > $SEM
else
	echo "Updateding semaphore file..."
	date > $SEM
fi

## Auditd keys to check
CHECK_KEYS=( "sshd" "identity" "susp_activity" "sbin_susp" "perm_mod" "file_modification" "file_access" "unauthedfileaccess" "priv_esc" "perm_mod" )
echo > $LOG
for i in ${CHECK_KEYS[@]};do
	echo "Check recent audit logs for key: $i"

	RESULT=$(ausearch --node eth.vm -ts recent -k $i)
	if [ -z "$RESULT" ]; then
		echo "No result... all fine!"
	else
		echo "SOME FUCKERY DTECTED WITH KEY: $i"
		echo "SOME FUCKERY DTECTED WITH KEY: $i" >> $LOG
		echo $RESULT >> $LOG

	fi

done

## if file is not empty, send mail
if [ -s ${LOG} ]; then
    echo "File empty..."
else
    echo "Alerts included..."
fi

