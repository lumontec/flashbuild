# FLASHbuild

FLASHbuild is your faster option for hacking with custom user/kernel space code. 
The project eats *Dockerfile + kernel binary/sources* and magically spits out a *initramfs image* that can be immediately loaded on qemu.
Includes a simple set of scripts to help you build and customize a fully bootable linux os image in the shortest time with a simple and intuitive Docker based process. 
This will cover all the cases in which you need a specialized quick and dirty linux distro for your personal hacks and projects without getting crazy with yocto and friends.
Can be used for testing custom executables or kernel modules (e.g. debugging both user and kernel interaction with gdb) in qemu on multiple architectures (arm64, amd64, powerpc, ..).

The project leverages the beauty and portability of latest docker buildkit technology, and takes inspiration by the excellent work of:

[https://mudongliang.github.io/2017/09/12/how-to-build-a-custom-linux-kernel-for-qemu.html](https://mudongliang.github.io/2017/09/12/how-to-build-a-custom-linux-kernel-for-qemu.html)  
[https://mgalgs.github.io/2015/05/16/how-to-build-a-custom-linux-kernel-for-qemu-2015-edition.html](https://mgalgs.github.io/2015/05/16/how-to-build-a-custom-linux-kernel-for-qemu-2015-edition.html)  

### Let`s roll ...
Lets build ubuntu.. in 3 minutes.. after setup obviously

##### 0 Setup your system

Install all the requirements:
```bash
sudo apt update
sudo apt install git make gcc device-tree-compiler bison flex libssl-dev libncurses-dev gcc-arm-linux-gnueabi gcc-aarch64-linux-gnu
```
Install and configure docker
```bash
# Install required docker tools
sudo apt install docker-ce
# Check your docker version > 19.0
docker --version
#Docker version 19.03.14, build 5eb3275d40
```
Configure docker extended features (buildx)
```bash
# Install binfmt cross instruction support
docker run --privileged --rm tonistiigi/binfmt --install all
# Stop docker services before reconfiguration
sudo systemctl stop docker docker.service
#set: "experimental": "enabled" in your ~/.docker/config.json
#set: '{"experimental": true}'  in your /etc/docker/daemon.json
sudo systemctl start docker docker.service
# Check buildx supported architectures for your node
docker buildx ls
# default default  running linux/amd64, linux/arm64, linux/riscv64, linux/ppc64le, linux/s390x, linux/386, linux/arm/v7, linux/arm/v6
```
Install qemu-kvm for emulation
```bash
sudo apt install qemu-kvm qemu virt-manager virt-viewer libvirt-bin qemu-system-aarch64 qemu-system-arm
```

##### 1 FLASH your OS
Ok now we can start having some fun..

Load ubuntu project:
```bash
make load PROJ=./flash/projects/ubuntu
yes
```

Steal your host kernel binary and change permissions:
```bash
cd ./workspace
sudo cp /boot/vmlinuz .
sudo chmod 755 vmlinuz
```

Now have a look at the current workspace
We use a simple Dockerfile and an init script to mount an initramfs after the kernel is loaded. These are the steps in a nutshell:
- pull base image
- install the packages that we want
- create some user
- add an init script to be called by the kernel
- that's it !

Dockerfile:
```Dockerfile
# Base image ---------------------------

FROM ubuntu:20.04 AS base
RUN  apt update 
RUN  apt -y upgrade 

# Install systemd init system
RUN  apt install -y systemd udev

# Change password for root
RUN echo "root:root" | chpasswd

# Add init script
ADD ./initramfs/init init
```

And this is the Init file:

```bash
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev
echo -e "\nBoot took $(cut -d' ' -f1 /proc/uptime) seconds\n"
exec /bin/sh
```

Now generate initramfs compressed archive:
```bash
make all
```
##### 2 Emulate
Setup your emulate.sh file and launch it
```bash
./emulate-x86.sh
...
...

[  OK  ] Reached target Graphical Interface.
         Starting Update UTMP about System Runlevel Changes...
[  OK  ] Finished Update UTMP about System Runlevel Changes.

Ubuntu 20.04.1 LTS localhost ttyS0

localhost login: 

```

How long did it take ?

##### 3 Disclaimer

I use this when i need to compile and debug the kernel and to test what syscalls provoke inside the kernel itself. Also this project is based on buildkit so that you can cross compile the whole thing across multiple architectures. 

Inside ./flash/projects folder you can find different projects tacling diverse use cases. 
Have fun !





