#!/usr/bin/env bash
## Other methods, such as systemd timers, exist for scheduling jobs. If another method is used, cron should be removed, and the alternate method should be secured in accordance with local site policy

## crontab
chown root:root /etc/crontab
chmod og-rwx /etc/crontab

chown root:root /etc/cron.hourly/
chmod og-rwx /etc/cron.hourly/

chown root:root /etc/cron.daily/
chmod og-rwx /etc/cron.daily/

chown root:root /etc/cron.weekly/
chmod og-rwx /etc/cron.weekly/

chown root:root /etc/cron.monthly/
chmod og-rwx /etc/cron.monthly/

chown root:root /etc/cron.d/
chmod og-rwx /etc/cron.d/

[ ! -e "/etc/cron.allow" ] && touch /etc/cron.allow
chown root:root /etc/cron.allow
chmod u-x,g-wx,o-rwx /etc/cron.allow

[ -e "/etc/cron.deny" ] && chown root:root /etc/cron.deny
[ -e "/etc/cron.deny" ] && chmod u-x,g-wx,o-rwx /etc/cron.deny


## at, if command exist, apply restrictions
[ ! "command -v at" ] && { [ ! -e "/etc/at.allow" ] && touch /etc/at.allow; chown root:root /etc/at.allow; chmod u-x,g-wx,o-rwx /etc/at.allow; \
	[ -e "/etc/at.deny" ] && chown root:root /etc/at.deny;  [ -e "/etc/at.deny" ] && chmod u-x,g-wx,o-rwx /etc/at.deny;}

