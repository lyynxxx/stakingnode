![Title](https://angelhost.eu/cg_validator.jpg)

So… why I'm writing this? For fun and experimenting purposes only! And for profit... Anyone (well... 98% of the people) who claims to be here just because of technology, is lying! Every miner dreams of a significant profit, 99% of miners never give a damn about any project/the tech, if a coin is not profitable to mine, they jump into an other one or just shuts down the rigs/ASICs. Validators are a bit different, but not much. While miners has to invest serious resources into hardware and operations, they have more options: mine different coins or sell the hardware. As a validator you have to invest into one project and can't jump in and out so quick(for example the ETH2.0 lockup), but in the end, as a validator you hope significant profit too.

The beauty of the decentralized operation is, that anyone can participate. Anyone who possesses the necessary knowledge and resources. But this needs work and dedication. If you start a validator, the backbone of the network, they reward you for securing the network. On the other hand, as soon as you fail in the duty for which you have applied, you get a penalty. Your best interest is to provide a secure node and service uptime as close as possible to 100%.

The networks greatest strength is also its greatest weakness. It is true that anyone can participate, but if most people don’t know what they’re doing, they just dream about breath taking profit, the whole network is doomed! So I  will try to think a little more carefully about the steps required to get your validator node mostly secure and well configured. Also, as time is money, I try to do this as automated as possibel so if anything goes wrong and I need to spin up a new machine to replace the old one, I can do it ASAP!

I write this for Dudes and Dudettes, who has some spare parts at home. While it's by no means the most recommended way, if you have a good internet connection, stable elecrtic network and time to learn and have fun, you can use this repo, to spin up a new machine at home and help secure the network.

# My own full validator or staking service?
A staking service can be tempting, for most people. You do not have to deal with hardware or software, as a service user – in theory – you will have up to 99.9% uptime and you don’t have to fear slashing or any penalties as you were offline.

Some services like RocketPool and Stkr are also for people without the full 32 ETH required to stake and run their own node. On the other hand, you have much less control over your investment, and you have to trust the service providers.

If you run your own validator node, you have all the responsibility to keep your node up to date and running all the time. You need some skills and must understand, you can’t pause the network, while you google for the solution if your system breaks. You must have backups and a method to spin up a new validator ASAP if needed.
If you never saw a Linux terminal or feel uncomfortable without any graphical interface, I suggest the staking services, or you can easily lose your ETH you can’t solve a system error. 

I encourage you to experiment on test nets but running a validator can be hard. The possibility should be considered, you need to work on weekend, on a day off, you cannot go on vacation as something comes up. If your validator spends too much time offline, you will lose some ETH or if your balance drops below the threshold, your validator can be removed from the active validator set and your funds will be locked while the withdrawal functions are ready. (As you may know staking is one way only at the moment. Depositing your ETH will lock it up, until the transition from the PoW chain to the PoS chain is complete. You cannot change your mind and withdraw your funds!)

Personally, I will build my own validator node! I am aware of the risks!

# Validator at home or run stuff in the Cloud?
The beauty of the decentralization, that anyone can participate, if you have the required skills and hardware. You can run a validator node at home, if you have stable internet and electricity. Of course, it does matter which network we're talking about! This will be mostly about Eth, but running a Sentry config on Cosmos/Crypto.org Chain is not recommended (or possible) at home (if you have only one public/dynamic IP). Solana requires extremly high network bandwidth (300Mbit/s symmetric, commercial. 1GBit/s preferred), which most home user don't have.

You can use cloud providers, VPS providers too. In this case – again – you don’t have to worry about the hardware and internet, but you must build up the system. In most cases you can spin up new nodes with a base system in about 5 minutes from base images. These are pre-built, easy to scale operating systems, but you can’t make any deep customization as they are often optimized for the infrastructure of the service provider.

While it is certainly easy and has the perks, you must consider the fact, that service providers can suspend your account any time. Service providers may or may not see your traffic, even the data inside your virtual machine, and if they have access to your validator keys… ye, not a fan of the idea.

On the other hand, if you run your validator at home, and you have daily downtimes as your internet service provider is not stable, or the electric grid fails often and the validator is offline as there is no power in the area, you also will lose the rewards or even part of your investment.

This is up to your own risk tolerance. In most cases running a validator at home is fine, but people should be aware of the risks!
There are pre-build systems, mini-PCs which are configured to run the beacon chain and the validator software, like Avado (https://ava.do/#about). They are easy to use and saves you from the installation and configuration part. But what happens if the hardware fails? Can you export your keys and start a new validator? Or do you order two right away, so you have a spare?

I do not want to tell anyone what to do, just thinking about possible failures. I have 32ETH and I do not want to lose it, I want to protect it! So, I must understand how the validator works, I must have backups and a disaster recovery plan, which will spare me from slashing.

I chose to build my own validator at home as it supports decentralization. If most of us would use AWS, Azure, GCP or any cloud provides, there would be no decentralization, and the big providers could control/attack the network.

# Hardware (for the ETH Beacon Chain)
Best place to start: (https://launchpad.ethereum.org/en/checklist)

This page will give you some good information about the hardware you need. The most important is, you will need SSD storage to consistently handle necessary read/write speeds, and you do not want cheap SSD!

1TB SSD (nvme or sata), a reliable one, with good warranty and customer service. 16-32GB RAM and a cpu with 4-8 cores would do the job, but this depends on the client software needs.

Simple hard disks will not be suitable for the task! Also, I do not recommend Raspberry Pi or other SBC platforms. Maybe after the merge, but not now.

I have a motherboard with X79 chipset, a Xeon e5-2620 processor and 32GB ECC ram (server grade stuff) and 1TB Samsung 860Pro. This will be fine.

# Operating system
This could lead to a dark forest. If you are a Windows or MAC fan, check which client supports your system and use it. First on test net of course. I recommend checking all the clients, the install process, recovery process and even the migration from one client to another one. You may need this if a bug breaks one validator client, others are not necessarily affected.

I am not a fan of Windows nor Apple when it comes to mission critical systems. Stone me…. I do not care. I use Linux servers, so I will use Linux here too. However not Ubuntu, like in 98% of the guides and tutorials. My personal system of choice is openSUSE or Red Hat/CentOS/Rocky Linux.

Most of the people will use Linux too. There are other alternatives, like DappNode (https://dappnode.io/), which will handle most of the process and you can set up everything from a browser window. Check all of them, play a little, and decide! There are more then one solutions!

# Software components
As you can see on the https://eth.wiki/eth2/clients page, there are a lot of beacon chain clients.

My personal choices at the time are: Prysm, Teku and Lighthouse. They are just working.

I have tested methods for system setup using these clients and even migration steps from one to another. Check the client docs and choose wisely!

As for the eth1 node, you can use Infura, Alchemy or some other service providers node but building on them can be a single point of failure. Better to run your own node, or with trusted friends, partners run one node and use it together. However I can recommend this kind of service providers as a backup Eth1 client. The free plan is a good solution if you need a new eth1 client, within 2 minutes, only for a few days, while you backup system syncs up fully.

My personal choice is Geth. This is where you need the SSD! Downloading and later just syncing, processing the eth1 network transactions require a significant amount of storage and I/O speed. Simple, consumer grade hard disks cannot do the task. I would not recommend cheap SSDs, buy one with great durability, with a large number as endurance rating. On my servers I use Intel D3-S4510 Series SSDs as they have 5 yr warranty and a total of 6.5 Petabyte total write capacity.

In the validator I use a Samsung P883 – it is a datacenter grade SSD – is also affordable and may worth the price ad you will run a “32ETH system” on it.

# Testing
Before you go to mainnet, it is a wise approach to spend some time on test nets. Experiment.

What happens if:

-	Power loss: will your validator start automatically?
-	Internet outage: will your validator reconnect automatically?
-	Operating system updates: can you create restoration points? Can you revert a system update?
-	Resources: can you add more ram/disk is needed?
-	Client bugs: can you change quickly to another client if a bug breaks the one you use?

You need monitoring. You need constant system metrics and alerting too, otherwise you will not know if your validator is offline or will be offline soon, and you need to do countermeasures. 

Most of the clients are supporting Prometheus and have a Grafana dashboard. Setting up a monitoring stack is essential!

# Some other stuff
I plan to do the system setup and most of the task automated. In this way I can reproduce all steps in the same way and the new node will be the same as the previous one.

I plan to make some advanced – well, I like to believe – system customizations. Default installs are good for a general-purpose PC, but I want more security, more system tuning, more optimization for this task.

I plan to pre-configure all I need, back it up and just download firewall settings, system files, service files, etc. into a fresh system.

I plan to use openSUSE as the host operating system, using a minimal install and AutoYast. As Red Hat closed CentOS – my previous choice of operating system – I move to Suse. I have used it before a lot for different tasks, it just works, and I like it.

AutoYast is Suse specific, but most of the commands and methods I use in the scripts after the operating system installation will work on almost any popular Linux.
Let us dive into the process and plan the base system.


 DISCLAIMER: I'm not an expert! Feel free to correct me (mailto: lyynxxx@gmail.com), as I don't want to misslead people, I just documenting my journey here.
 
