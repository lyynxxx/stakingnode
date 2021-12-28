## Cloud-init
Biggest change is preseed and kickstart files are deprecated in favor of cloud-init. Using ks=http://example.com/install.ks on boot command requires using the legacy-server image! Alternate install is deprecated, renamed to legacy-server install and all installs are supposed to use the full install iso.

It is still possible to use kickstart files. Keep in mind Canonical is making it clear that it's going away soon so may want to get used to the new installer.

### Basic usage
Create a path for a given install type on a webserver, create an empty meta-data file in that directory.
Enter the following at end of command, replacing the URL with the address to where the above files are located.
Copy one of the user-data files to that directory and make sure it is named user-data.
Boot from Ubuntu 20.04 ISO.
    autoinstall ds=nocloud-net;s=http://example.com/vm/
