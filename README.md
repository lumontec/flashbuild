# Flashbuild
Flashbuild is a simple set of scripts to help you build a fully bootable linux os image in the shortest time with a simple and intuitive process. 
Target is to cover all the cases in which you need a specialized quick and dirty linux distro for your personal hacks and projects without getting crazy with yocto and friends.
Can be used for testing an executable full stack (e.g. debugging both user and kernel interaction) in qemu as well as to create some simple bootable image for your cross platform bare metal hardware.
The project leverages the beauty and portability of latest docker technology, and takes inspiration by the excellent work of:

[https://mudongliang.github.io/2017/09/12/how-to-build-a-custom-linux-kernel-for-qemu.html](https://mudongliang.github.io/2017/09/12/how-to-build-a-custom-linux-kernel-for-qemu.html)
[https://mgalgs.github.io/2015/05/16/how-to-build-a-custom-linux-kernel-for-qemu-2015-edition.html](https://mgalgs.github.io/2015/05/16/how-to-build-a-custom-linux-kernel-for-qemu-2015-edition.html)

### Let`s roll ...
In this example we roll an extremely minimal image with no rootfs, everything gets loaded in ram by making use of initramfs:
##### 1 Build your minimal kernel
We clone the official kernel repo and build the core with default configuration for our arch
```bash
cd ./2_kernel/build
git clone https://github.com/torvalds/linux.git .
git checkout v5.9
make defconfig
make vmlinux -j8
```
Flashbuild will look inside the **/2_kernel/build** folder for the **vmlinux** binary.
##### 2 Generate your initramfs
We use a simple Dockerfile and an init script to mount an initramfs after the kernel is loaded
```bash
ls ./2_initramfs/build
Dockerfile  init
```
Dockerfile:
```Dockerfile
# Alpine linux
FROM alpine:latest
RUN apk update
# Install our init system
RUN apk add openrc
```
Init:
```bash

```

##### 3 Generate your rootfs
##### 4 Flashbuild your image
