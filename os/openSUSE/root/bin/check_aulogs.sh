#!/bin/bash

SEM=/root/check.sem

if ! [ -f $SEM ]; then
	echo "Creating semaphore file..."
	date > $SEM
else
	echo "Updateding semaphore file..."
	date > $SEM
fi

## Auditd keys to check
CHECK_KEYS=( "sshd" "identity" "susp_activity" "sbin_susp" "perm_mod" "file_modification" "file_access" "unauthedfileaccess" "priv_esc" "perm_mod" )

for i in ${CHECK_KEYS[@]};do
	echo "Check recent audit logs for key: $i"

	RESULT=$(ausearch --node eth.vm -ts recent -k $i)
	if [ -z "$RESULT" ]; then
		echo "No result... all fine!"
	else
		echo "SOME FUCKERY DTECTED WITH KEY: $i"
	fi

done
