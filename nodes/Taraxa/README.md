## Taraxa Project

Taraxa is a public ledger platform purpose-built for audit logging of informal transactions.
Check details [on their web site](https://www.taraxa.io) or [in this Medium article](https://medium.com/taraxa-project/democratizing-reputation-by-tracking-informal-transactions-6e32ef229b42)

## Testnet node setup - options

[Reading the official guide](https://docs.taraxa.io/node-setup/testnet_node_setup), looks like developers providing you container images, and you don't have to bother with complex setup and tuning processes. They even have scripts for different VPS providers to help new, less experienced node operators, which is really nice! However all the containers are running as root and I like to avoid this in a production environment. Even for the testnet. As for the base OS setup you can check my openSUSE system design and install notes. To run the containers as non-root user, you have two options.

First, you can use Docker daemon as a non-root user too. [Details here](https://docs.docker.com/engine/security/rootless/). The Docker Team have installation guides for different systems, like Ubuntu, Debian, Arch, Suse, etc.

Or you can use [Podman](https://podman.io/).
Podman is a daemonless container engine for developing, managing, and running OCI Containers on your Linux System. Containers can either be run as root or in rootless mode. And that's what we want! As escaping a container is very possible, this way if someone breaks out of the box, only get a limited permission on the host!

Besides containers, if you don't want to bother with container images, you can build the binary by yourself. [There is a detailed guide](https://github.com/Taraxa-project/taraxa-node/blob/develop/doc/building.md), which you can almost fully copy-paste on a freshly installed Ubuntu 20.04LTS system, and you can easily build the taraxad binary. Signing the proof of ownership is a bit harder this way, but I will cover it later.

I recommend to separate the buildin environment and the production node. In general I don't like any compiler on a production server if it's not essential! Mostly it is not! In this scenario you need two servers or VMs. One will be the buildong tool and the other one will be the taraxa node.

### Podman

Moving from Docker Open Source Engine to Podman does not require any changes in any established workflow. There is no need to rebuild images, and you can use the exact same commands to build and manage images as well as running and controlling containers. [The Suse documentation has a good summary](https://documentation.suse.com/sles/15-SP3/html/SLES-all/cha-podman-overview.html)

Install podman using the [official guide](https://podman.io/getting-started/installation) to your system.
As I'm using openSUSE it's simply:
```
#zypper in podman
```

Podman differs from Docker Open Source Engine in two important ways.

 - Podman does not use a daemon, so the container engine interacts directly with an image registry, containers, and image storage. As Podman does not have a daemon, it provides integration with systemd. This makes it possible to control containers via systemd units. You can create these units for existing containers as well as generate units that can start containers if they do not exist in the system. Moreover, Podman can run systemd inside containers.

 - Because Podman relies on several namespaces, which provide an isolation mechanism for Linux processes, it does not require root privileges to create and run containers. This means that Podman can run in the root mode as well as in an unprivileged environment. Moreover, a container created by an unprivileged user cannot get higher privileges on the host than the container's creator. (!!!)

To enable rootless mode for your non-privileged user, run the following command as root (If you have an already installed system follow the [official guide](https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md)) :
```
 #usermod --add-subuids 200000-201000 --add-subgids 200000-201000 YOURUSER
```
Rootless Podman requires the user running it to have a range of UIDs listed in the files /etc/subuid and /etc/subgid. The shadow-utils or newuid package provides these files on different distributions and they must be installed on the system. Root privileges are required to add or update entries within these files. 

For each user that will be allowed to create containers, update /etc/subuid and /etc/subgid (the command above) for the user with fields that look like the following. Note that the values for each user must be unique. If there is overlap, there is a potential for a user to use another user's namespace and they could corrupt it.

```
#cat /etc/subuid
YOURUSER:200000:1001

```

A fast reboot is required.

From now on you can pull and run container images with a non-privileged user. 
Let's  chek out, if podman can find the images as YOURUSER:

```
$podman search taraxa
INDEX       NAME                                         DESCRIPTION             STARS   OFFICIAL   AUTOMATED
docker.io   docker.io/taraxa/taraxa-node                                         0
docker.io   docker.io/taraxa/explorer                                            0
docker.io   docker.io/taraxa/taraxa-node-status                                  0
docker.io   docker.io/taraxa/taraxa                                              0
docker.io   docker.io/taraxa/sandbox                                             0
docker.io   docker.io/taraxa/taraxa-community-frontend                           0
docker.io   docker.io/teguhsuandi/dandelion              Taraxacum Asteraceae.   0
```

As you can see, these are the official images. Download the node.
```
$podman pull docker.io/taraxa/taraxa-node
Trying to pull docker.io/taraxa/taraxa-node...
Getting image source signatures
Copying blob 410a49d53da6 done
Copying blob 27b19c376170 done
Copying blob 2ad5178b630a done
Copying blob 1ca1ce97a3b6 done
Copying blob 7b1a6ab2e44d done
Copying blob 7d7dc3df991e done
Copying blob 8581f8f8cbd2 done
Copying blob 2605d1e01516 done
Copying blob 5624488237d7 done
Copying config 4492fc7c06 done
Writing manifest to image destination
Storing signatures
4492fc7c0694ab7d3decadd10da44cc23358dd0616348dbc81c3fcbe1ad98334
```

Check the image version:
```
$podman images --digests
REPOSITORY                    TAG     DIGEST                                                                   IMAGE ID      CREATED       SIZE
docker.io/taraxa/taraxa-node  latest  sha256:ba6937e8cbc07738603f65485f5b128ff160839aa6f43de0c3e97f4370e8e30d  4492fc7c0694  16 hours ago  688 MB
```

Now we have the container, but we still need to create the storage for the config files and the chain data.
On my node, I use the following directories:

Config files: /opt/taraxa/.conf

Chain data:   /opt/taraxa/data

Let's create these folders and set permissions, so only my user could have access to the files.
```
mkdir -p /opt/taraxa/.conf
mkdir -p /opt/taraxa/data
chown -R YOURUSER:root /opt/taraxa
chmod 700 /opt/taraxa
```

If you have a wallet and a config file, you can copy them into the /opt/taraxa/.conf folder. The taraxad binary will read them.
If you don't have any wallet jet, on the first start the taraxad binary will create one. Keep these files safe! You can always re-sync the chain data, but you can't recover your wallet!

Start the node:
```
$podman run -d -p 7777:7777 -p 10002:10002 -p 10002:10002/udp --name=taraxa-node1 --mount type=bind,source=/opt/taraxa/.conf,target=/opt/taraxa_data/conf --mount type=bind,source=/opt/taraxa/data,target=/opt/taraxa_data/data docker.io/taraxa/taraxa-node taraxad --network-id 2 --wallet /opt/taraxa_data/conf/wallet.json --config /opt/taraxa_data/conf/testnet.json --data-dir /opt/taraxa_data/data --overwrite-config
```
 * podman run -d : create a new container and start it in the background
 * -p port_on_the_server:port_in_the_container: this is how we can expose ports used by the container. 7777 -> rpc port, 10002/tcp and 10002/udp are the ports user by the Taraxa network clients to communitace eachother.
 * --name: gives a name to the container. If non present, podman will generate a random name.
 * --mount: this will map a folder in the server to a folder or file in the container. For example:  source=/opt/taraxa/.conf (this is in the host) and will appear as target=/opt/taraxa_data/conf in the container.
 * --wallet, --config, --data-dir are taraxad parameters. These tells the binary what config files and directories to use INSIDE the container

Check the container and the logs:
```
$ podman ps
CONTAINER ID  IMAGE                                COMMAND               CREATED      STATUS          PORTS                                               NAMES
a7c70bf16572  docker.io/taraxa/taraxa-node:latest  taraxad --network...  3 hours ago  Up 3 hours ago  0.0.0.0:10002->10002/tcp, 0.0.0.0:10002->10002/udp  taraxa-node1
```

```
podman logs -f taraxa-node1
Starting taraxad...
0x00007f820ca00300 FULLND [2021-12-28 11:51:13.424188] SILENT: Node public key: ea27f106712e92961c058df725dc5cce43d30bbffd2a5fd8f03a329a0375b762e71e2209e494ddd61e71cacf8c0e60e822d16fe421ef9748561d1ee1c74cc2f0
Node address: 2fdc4badc80a53980003e5e606266fe0eb4381db
Node VRF public key: 7c0495458b57edf3cb27b7c5a680edd5d29ee6ad086079f25d74530f5e742b78
0x00007f809effd700 VOTE_MGR [2021-12-28 11:51:42.970402] SILENT: Retrieve verified votes from DB
0x00007f820ca00300 RPC [2021-12-28 11:51:43.114742] SILENT: Taraxa RPC started at port: 7777
0x00007f820ca00300 RPC [2021-12-28 11:51:43.114950] SILENT: Taraxa WS started at port: 0.0.0.0:8777
Taraxa node started
0x00007f805d7fa700 STATUS_PH [2021-12-28 11:51:50.716124] ERROR: Incorrect node version: 0, our node version1.18.0, host f299bdd3… will be disconnected
0x00007f805cff9700 STATUS_PH [2021-12-28 11:51:50.797133] ERROR: Incorrect node version: 0, our node version1.18.0, host 459172df… will be disconnected
0x00007f8057fff700 STATUS_PH [2021-12-28 11:51:50.858112] ERROR: Incorrect node version: 0, our node version1.18.0, host 00dc4b46… will be disconnected
0x00007f80577fe700 STATUS_PH [2021-12-28 11:51:51.157327] ERROR: Incorrect node version: 0, our node version1.18.0, host ac829cb5… will be disconnected
0x00007f804e7fc700 VOTES_SYNC_PH [2021-12-28 11:51:51.174307] ERROR: There are empty next votes for previous PBFT round
0x00007f8056ffd700 STATUS_PH [2021-12-28 11:51:55.997348] ERROR: Incorrect node version: 0, our node version1.18.0, host 00dc4b46… will be disconnected
0x00007f80567fc700 STATUS_PH [2021-12-28 11:51:56.378543] ERROR: Incorrect node version: 0, our node version1.18.0, host ac829cb5… will be disconnected
0x00007f8055ffb700 STATUS_PH [2021-12-28 11:52:00.283464] ERROR: Incorrect node version: 0, our node version1.18.0, host fa482a58… will be disconnected
0x00007f8054ff9700 STATUS_PH [2021-12-28 11:52:00.400369] SILENT: Restarting syncing PBFT from peer ##d21ffcfb…, peer PBFT chain size 159636, own PBFT chain synced at period 38790
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:13.113602] INFO: Connected to 1 peers: [ d21ffcfb… ]
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:13.113727] INFO: Syncing for 0 seconds, 24% synced
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:13.113748] INFO: Currently syncing from node ##d21ffcfb…
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:13.113773] INFO: Max peer PBFT chain size:       159636 (peer ##d21ffcfb…)
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:13.113792] INFO: Max peer PBFT consensus round:  389930 (peer ##d21ffcfb…)
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:13.113813] INFO: Max peer DAG level:             759364 (peer ##d21ffcfb…)
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:13.113830] INFO: Max DAG block level in DAG:      0
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:13.113853] INFO: Max DAG block level in queue:    0
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:13.113871] INFO: PBFT chain size:                 38905
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:13.113886] INFO: Current PBFT round:              1
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:13.113900] INFO: DPOS total votes count:          1825
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:13.113918] INFO: PBFT consensus 2t+1 threshold:   667
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:13.113939] INFO: Node elligible vote count:       0
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:13.113986] INFO: ------------- tl;dr -------------
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:13.114012] INFO: STATUS: GOOD. ACTIVELY SYNCING
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:13.114029] INFO: In the last 0 seconds...
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:13.114045] INFO: PBFT sync period progress:      39165
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:13.114075] INFO: PBFT chain blocks added:        38905
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:13.114098] INFO: PBFT rounds advanced:           1
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:13.114115] INFO: DAG level growth:               0
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:13.114131] INFO: ##################################
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:43.114222] INFO: Connected to 5 peers: [ 2bf27d79… d21ffcfb… bf2a3d60… d1f4bc91… 41e6587e… ]
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:43.114341] INFO: Syncing for 30 seconds, 24% synced
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:43.114362] INFO: Currently syncing from node ##d21ffcfb…
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:43.114379] INFO: Max peer PBFT chain size:       159636 (peer ##2bf27d79…)
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:43.114395] INFO: Max peer PBFT consensus round:  389935 (peer ##2bf27d79…)
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:43.114410] INFO: Max peer DAG level:             759364 (peer ##2bf27d79…)
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:43.114426] INFO: Max DAG block level in DAG:      0
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:43.114440] INFO: Max DAG block level in queue:    0
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:43.114454] INFO: PBFT chain size:                 39172
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:43.114468] INFO: Current PBFT round:              1
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:43.114484] INFO: DPOS total votes count:          1825
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:43.114498] INFO: PBFT consensus 2t+1 threshold:   667
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:43.114515] INFO: Node elligible vote count:       0
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:43.119185] INFO: ------------- tl;dr -------------
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:43.119230] INFO: STATUS: GOOD. ACTIVELY SYNCING
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:43.119248] INFO: In the last 30 seconds...
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:43.119264] INFO: PBFT sync period progress:      250
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:43.119279] INFO: PBFT chain blocks added:        267
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:43.119293] INFO: PBFT rounds advanced:           0
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:43.119308] INFO: DAG level growth:               0
0x00007f804f7fe700 SUMMARY [2021-12-28 11:52:43.119324] INFO: ##################################

```

Looks fine. It's syncing...

If you are extra paranoid, you can lock this user, so it is not even able to log in with ssh or get a shell. The setup and managemnt process will be a bit different in this case as you must be extra carefull and run all the user commands as root with a temporary shell.
For example:
```
su - taraxa -s /bin/bash -c "podman pull docker.io/taraxa/taraxa-node"
or
su - taraxa -s /bin/bash -c "podman start taraxa-node1"
su - taraxa -s /bin/bash -c "podman logs -f taraxa-node1"
```

su - taraxa -> run the following command as the user "taraxa", our service user
-s /bin/bash -> use this temporary bash shell
-c "" -> the command to execure in the taraxa user namespace

### Self compiled binary

It is always a good practice to build the binary on a different system. If you have the binary, you need only a few step to run your own taraxa node.
First of all, we need a locked service user (as root):

```
#groupadd taraxa
#useradd --system -g taraxa -d /opt/taraxa --shell /bin/false taraxa
#mkdir -p /opt/taraxa/bin
#mkdir -p /opt/taraxa/data
#mkdir -p /opt/taraxa/.conf
```

On the building VM, you can create a wallet and configuration file for the testnet.
Assuming you copy-pasted the tutorial while you created the environment to compile the binary, replace only the username:

```
$/home/YOURUSERNAME/taraxa-node/cmake-build/bin/taraxad --command config

Configuration file does not exist at: /home/YOURUSERNAME/.taraxa/config.json. New config file will be generated
Wallet file does not exist at: /home/YOURUSERNAME/.taraxa/wallet.json. New wallet file will be generated
```

Save these files! Also copy them to the node, in the folder /opt/taraxa/.conf/
Copy the compiled /home/YOURUSERNAME/taraxa-node/cmake-build/bin/taraxad binary to the node, in the folder /opt/taraxa/bin/

Fix the permissions and file ownerships:
```
chown -R taraxa:taraxa /opt/taraxa
chmod +x /opt/taraxa/bin/taraxad
chmod 750 /opt/taraxa
```

Create systemd.service file to manage and auto start the service at boot time. /etc/systemd/system/taraxa.service
(check the wallet and config file names!)
```
[Unit]
Description=Taraxa node. 
After=network.target 
Wants=network.target

[Service]
User=taraxa 
Group=taraxa
Type=simple
Restart=always
RestartSec=5
LimitNOFILE=5120
LimitNPROC=5120
ExecStart=/opt/taraxa/bin/taraxad --data-dir /opt/taraxa/data --config /opt/taraxa/.conf/config.json --wallet /opt/taraxa/.conf/wallet.json
InaccessibleDirectories=/home /var /usr /root
ReadOnlyDirectories=/etc
PrivateTmp=yes
NoNewPrivileges=yes
PrivateDevices=true
ProtectControlGroups=true
ProtectHome=true
ProtectKernelTunables=true
ProtectSystem=full
RestrictSUIDSGID=true

[Install]
WantedBy=default.target
```

Reload systemd services, enable and start the service:
```
systemctl daemon-reload
systemctl enable taraxa
systemctl start taraxa
```

Check the logs:
The binary logs under /opt/taraxa/data/logs or you can use journalctl:
```
#journalctl -fu taraxa
```

### Proof of ownership

You need the building environment and your wallet file, check your wallet file for the following lines: node_secret, node_address.
You need to format them. A small prefix is a must "0x" before you can use them, as you can see soon.

YOURPRIVATE_KEY = 0xnode_secret (in my case: 0x85096c68cab805e964c24a0ef406c71a641d102301857197d7b2d8cf77d615ea)
YOURTEXT = 0xnode_address (in my case: 2fdc4badc80a53980003e5e606266fe0eb4381db)

type "python3" in a console and press enter. Run the following code, change the variables as your needs:
```
import json
from eth_account import Account
from eth_utils.curried import keccak
account = Account.from_key(YOURPRIVATE_KEY)
text = "YOURTEXT"
sig = account.signHash(keccak(hexstr=text))
sig_hex = sig.signature.hex()
print(sig_hex)
```

The output will be something like this:
```
0x3bada8cd78d6abd36b46d41ee2c15d040a4f087c24bd064749b1754dc316ec167b6070fc4f4e46c5f0e70b5c2f5c2ca28fa840a5afd3e883107edd2c5cb8dd361c
```

This is the information you need to register your node in the community site.


If you use containers you can follow the [official docs](https://docs.taraxa.io/node-setup/proof_owership), just replace docker with podman.
Use "podman ps" to check the container name. In this case it is "taraxa-node1".
```
$podman ps
CONTAINER ID  IMAGE                                COMMAND               CREATED      STATUS          PORTS                                               NAMES
a7c70bf16572  docker.io/taraxa/taraxa-node:latest  taraxad --network...  6 hours ago  Up 6 hours ago  0.0.0.0:10002->10002/tcp, 0.0.0.0:10002->10002/udp  taraxa-node1

$podman exec taraxa-node1 taraxa-sign sign --wallet /opt/taraxa_data/conf/wallet.json
0x3bada8cd78d6abd36b46d41ee2c15d040a4f087c24bd064749b1754dc316ec167b6070fc4f4e46c5f0e70b5c2f5c2ca28fa840a5afd3e883107edd2c5cb8dd361c

```