#!/bin/bash

SEM=/root/check.sem

if ! [ -f $SEM ]; then
	echo "Creating semaphore file..."
	date > $SEM
else
	echo "Updateding semaphore file..."
	date > $SEM
fi

echo "Checking sshd configs:"
RESULT=$(ausearch --node eth.vm -ts recent -k sshd)
if [ -z "$RESULT" ]; then
	echo "No result... all fine!"
else
	echo "SSH CONFIG FUCKERY DETECTED!!!"
fi

echo "Checking /etc/shadow:"
RESULT=$(ausearch --node eth.vm -ts recent -k etcshadow)
if [ -z "$RESULT" ]; then
	echo "No result... all fine!"
else
	echo "/ETC/SHADOW FUCKERY DETECTED!!!"
fi

echo "Checking /etc/passwd:"
RESULT=$(ausearch --node eth.vm -ts recent -k etcpasswd)
if [ -z "$RESULT" ]; then
	echo "No result... all fine!"
else
	echo "/ETC/PASSWD FUCKERY DETECTED!!!"
fi

echo "Checking susp_activity:"
RESULT=$(ausearch --node eth.vm -ts recent -k susp_activity)
if [ -z "$RESULT" ]; then
	echo "No result... all fine!"
else
	echo "SOME FUCKERY DETECTED!!!"
fi

echo "Checking sbin_susp:"
RESULT=$(ausearch --node eth.vm -ts recent -k sbin_susp)
if [ -z "$RESULT" ]; then
	echo "No result... all fine!"
else
	echo "SOME ADVANCED FUCKERY DETECTED!!!"
fi

echo "Checking perm_mod:"
RESULT=$(ausearch --node eth.vm -ts recent -k perm_mod)
if [ -z "$RESULT" ]; then
	echo "No result... all fine!"
else
	echo "SOME PERMISSION FUCKERY DETECTED!!!"
fi

echo "Checking file_modification:"
RESULT=$(ausearch --node eth.vm -ts recent -k file_modification)
if [ -z "$RESULT" ]; then
	echo "No result... all fine!"
else
	echo "SOME FILE MOD FUCKERY DETECTED!!!"
fi