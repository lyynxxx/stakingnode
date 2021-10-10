![Title](https://angelhost.eu/cg_validator.jpg)

So… why I'm writing this? For fun and experimenting purposes only, so that I can remember what I did and why! And ofc for profit... Everyone (well... 98% of the people) who claims to be here just because of the technology, is lying! Every miner dreams of a significant profit, majority of miners doesn’t give a damn about any project/the tech, if a coin is not profitable to mine, then they jump into an other one, or just shut down the rigs/ASICs. Validators are a bit different, but as I experience, not significantly. Miners have to invest serious resources into hardware and operation, and they have more options: mine different coins or/and sell the hardware. As a validator, you have to invest into one project and can't jump in and out so quick (for example the ETH2.0 lockup), but in the end, you can hope significant profit too (sadly that is the only reason many even consider it).

The beauty of the decentralized operation is that anyone can participate in it. Anyone who acquires the necessary knowledge and holds the necessary resources. However, this needs work and dedication. If you start a validator - the backbone of the network - , they reward you for securing the network. On the other hand, as soon as you fail in the duty for which you have applied, you may get a penalty. Your best interest is to provide a secure node and service uptime as close as possible to 100%.

The network’s greatest strength is also it’s greatest weakness: anyone can participate, but if people doesn’t know what they’re doing, then they are practically just dreaming about breathtaking profit, following half-baked guides from the internet and the whole network is about to collapse eventually. 
Because of that, I try to think carefully about the steps required to get a validator node, mostly secure and well configured. As time is money, I also try to do this as automated as possible, so that if anything goes wrong and I need to spin up a new machine to replace the old one, I could do it ASAP! It's mostly about ETH2.0, but the basics - the OS setup - are the same for almost any validator.


# My own, full validator or a staking service?
A staking service can be tempting for most people. You do not have to deal with hardware or software, as a service user – in theory – you will have up to 99.9% uptime and don’t have to fear of slashing or any penalties, as you were offline. The entry amount of the coins are mostly low so it doesn’t mean a huge investment.

Some services like RocketPool and Stkr are also for people without the full 32 ETH required to run their own staking node. On the other hand, you have much less control over your investment and you will depend on the service providers.

If you run your own validator node, you have all the responsibility to keep your node up-to-date and running all the time. You need some skills and have to accept that you can’t pause the network while you google for the solution in case of system breaks. You have to have backups and a method to spin up a new validator ASAP if necessary.
If you never saw a Linux terminal or feel uncomfortable without any graphical interface, I rather suggest you the staking services otherwise you can easily lose your ETH if you can’t solve a system error. 

I do encourage you to experiment on test nets, but keep in mind that running a validator can be difficult sometimes. It should be considered that you need to work during weekend, on a day off, or you cannot go on vacation as something comes up… etc. If your validator spends too much time offline, you will lose some ETH (or any other rewards). Also, if your balance drops below the threshold, your validator can be removed from the active validator set and your funds will be locked while the withdrawal functions are ready. (As you may know, staking ETH is a one way road at the moment. Depositing your ETH will lock it up, until the transition from the PoW chain to the PoS chain is complete. You can not change your mind and withdraw your funds!)

Personally, knowing these risks, I would build my own validator node. 

# Validator at home vs. run stuff in the Cloud/Data center?
The beauty of the decentralization is that anyone can participate - naturally, in case you have the required skills and hardware. You can run a validator node at home if you have stable internet and electricity. Obviously, it does matter which network we're talking about. This will be mostly about Eth, but running a Sentry config on Cosmos/Crypto.org Chain is not recommended (or even possible) at home (if you have only one public/dynamic IP). Solana requires extremely high network bandwidth (300Mbit/s symmetric, commercial. 1GBit/s preferred), which most home user doesn't have.

You can use cloud providers or VPS providers too. If you go this way – repeatedly – you don’t have to worry about hardware or internet, but you must build up the system itself. In most cases, you can spin up a new virtual server in about 5 minutes from base images. These are pre-built, easy-to-scale operating systems, but you can’t make many deep customization as they are often optimized for the infrastructure of the service provider.

While it is certainly easy and has the perks, you must consider the fact that service providers can suspend your account anytime. Service providers may or may not see your traffic - even the data inside your virtual machine, and if they have access to your validator keys… well, not a fan of the idea.

On the other hand, if you run your validator at home and you have daily downtimes as your internet service provider is not stable, or the electric grid fails often and the validator is offline as there is no power in the area, you will also lose the rewards and/or even part of your investment.

This is up to your own risk tolerance. In most cases running a validator at home is fine, but people should be aware of the risks.
There are pre-build systems, such as mini-PCs which are configured to run the beacon chain and the validator software, like Avado (https://ava.do/#about) or DAppNode (https://dappnode.io/). They are easy to use and you don’t have to deal with the installation and configuration part. But what happens if the hardware fails? Can you export your keys and start a new validator? Or do you order two right away, so you have a spare?

I do not want to tell anyone what to do, just thinking about possible failures. I have 32ETH and I do not want to lose it, I rather want to protect it! So, I have to understand how the validator works, and I must have backups and a disaster recovery plan which will spare me from slashing and a heart attack.

I chose to build my own validator at home as it supports decentralization. If most of us would use AWS, Azure, GCP or any cloud provides, there would be no decentralization and the big providers could control/attack the network.


# Hardware (for the ETH Beacon Chain)
Best place to start: (https://launchpad.ethereum.org/en/checklist)

This page will give you some good information about the hardware you will need. The most important is that you will need an SSD storage to consistently handle the necessary read/write speeds and you do not want a cheap SSD for this aim!

Minimum 1TB SSD (nvme or sata), a reliable one, with good warranty and customer service. 8-32GB RAM and a CPU with 4-8 cores would do the job, but it also depends on the client/software needs + the number of services you plan to run on the same system.

Simple hard disks will not be suitable for this task! Also, I do not recommend Raspberry Pi or other SBC platforms. Maybe after the merge, but definitely not at the starting point.

I have a motherboard with X79 chipset, a Xeon e5-2620 processor and 32GB ECC ram (server grade stuff) and 960GB Samsung P883. 

# Operating system
This could lead to a dark forest. If you are a Windows or MAC fan, check which client supports your system and use it. Initially on test net, of course. I recommend checking all the clients, the installation process, the recovery process and even the migration process from one client to another. You may need these if a bug breaks a validator client, others are not necessarily affected.

I am neither a fan of Windows nor Apple when it comes to mission critical systems. Stone me…. I do not care. I use Linux servers, so I will use Linux here too. However not Ubuntu, as referred in 98% of the guides and tutorials. My personal system of choice is openSUSE or Red Hat (but as they bleed out CentOS, SUSE is more preferred).

Most of the people will use Linux too. There are other alternatives, like DappNode (https://dappnode.io/), which will handle most of the process and you can set up everything from a browser window. Check all of them, play a little and decide! There is more then one solution!

# Software components
As you can see on the https://eth.wiki/eth2/clients page, there are lots of beacon chain clients.

My personal choices at the time are: Prysm, Teku and Lighthouse. They are just working as expected/designed. (I'm working on other clients too, my plan to support them all in my setup.)

I have tested methods for system setup using these clients and even migration steps from one to another. Check the client docs and choose wisely!

As for the eth1 node, you can use Infura, Alchemy or some other service providers node but building on them can be a risky (however if you accept the risks, you can spare a lot of SSD disk space and lifetime). Better to run your own node, or with trusted friends, partners run one node and use it altogether. However, I suggest to use service providers as a backup Eth1 client. The free plan is a good solution if you need a new eth1 client within 2 minutes, but only for a few days term while your backup system syncs up fully.

My personal choice is Geth. This is where you need the SSD! Downloading and later just syncing, processing the eth1 network transactions require a significant amount of storage and I/O speed. Simple, consumer grade hard disks cannot do that task. I would not recommend cheap SSDs, buy one with great durability with a large number, as endurance rating. On my servers I use Intel D3-S4510 Series SSDs as they have 5 years of warranty and a total of 6.5 Petabyte write capacity.

In the validator I use a Samsung P883 – it is a datacenter sata SSD – which is also affordable and worth the price as you will run a “32ETH system” on it.

# Testing
Before you go to mainnet, it is a wise approach to spend some time on test nets. Do Experiment it!

What happens if:

-	Power loss: will your validator restart automatically?
-	Internet outage: will your validator reconnect automatically?
-	Operating system updates: can you create restoration points? Can you revert a system update?
-	Resources: can you add more ram/disk if needed?
-	Client bugs: can you change quickly to another client if a bug breaks the one you currently use?

You need monitoring. You need constant system metrics and alerting too, otherwise you will not know if your validator is offline or will be offline soon, and you need to do counter-measures.

Most of the clients are supporting Prometheus and have a Grafana dashboard. Setting up a monitoring stack is essential (on a different host)!

# Some other stuff
I plan to do the system setup and most of the task automated/scripted. This way I can reproduce all steps in the same way and the new node will be the same as the previous one.

I plan to make some – well, I like to believe – advanced system customizations. Default installations are good for a general-purpose PC but I want to assure more security, more system tuning and more optimization for this task.

I plan to pre-configure all I need, back it up and just download firewall settings, system files, service files, etc. into a fresh system.

I plan to use openSUSE as the host operating system, using a minimal install and AutoYast. As Red Hat closed CentOS – my previous choice of operating system – I move to Suse. I have used it before a lot for different tasks and it just works, I like it.

AutoYast is Suse specific, but most of the commands and methods I use in the scripts after the operating system installation will work on almost any popular Linux.
Let us dive into the process and plan the base system.


 DISCLAIMER: I'm not an expert! Feel free to correct me (mailto: lyynxxx@gmail.com), as I don't want to mislead people, I just documenting my journey here.
 If you find this useful, my coffee fund: ETH --  0xa29C271FF54667691A00359D23815353AC834B8f
