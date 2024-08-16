##### 1 Build your minimal kernel
We simply use a copy of our corrent host kernel binary
```bash
cp /boot/vmlinuz .
sudo chmod 777 ./vmlinuz
```
##### 2 Generate your initramfs
We use a simple Dockerfile and an init script to mount an initramfs after the kernel is loaded. These are the steps in a nutshell:
- pull base image
- install the packages that we want
- create some user
- add an init script to be called by the kernel
- thats it !

```Dockerfile
# Base image ---------------------------
# 
# We download a basic ubuntu image to copy
# our fs tree 

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
```
Init file:
```bash
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev
echo -e "\nBoot took $(cut -d' ' -f1 /proc/uptime) seconds\n"
exec /bin/sh
```

##### 4 Emulate
```bash
./emulate.sh
```


