#!/bin/bash
LOGFILE=/tmp/daily.log
echo > $LOGFILE

/usr/sbin/logwatch >> $LOGFILE
/usr/sbin/aureport --input-logs -ts yesterday 00:00:00 -te now --summary -i >> $LOGFILE
/usr/sbin/aureport --input-logs -ts yesterday 00:00:00 -te now -k --summary >> $LOGFILE
/usr/sbin/aureport --input-logs -ts yesterday 00:00:00 -te now -x --summary >> $LOGFILE
/usr/sbin/aureport --input-logs -ts yesterday 00:00:00 -te now --mac --summary >> $LOGFILE
/usr/sbin/aureport --input-logs -ts yesterday 00:00:00 -te now -i --login|tail -n5 >> $LOGFILE

cat ${LOGFILE} | /usr/bin/mailx -s 'Daily report (eth2)' lyynxxx@gmail.com

echo > $LOGFILE
