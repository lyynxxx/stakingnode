## What are modules?

Modules are simple bash scripts. List of commands, to create new service users, download binary packages and configuration files, set up services to start az boot time, etc.

I created these files, so I could do every installation in the same way. I just need to include the module I wish to install in the kickstart/AutoYast file, and it will be executed during the operating system installation.

This will not do all the magic, some manual work is required, but it covers aboout 90% of the process.
