##### 1 Build your minimal kernel
We clone the official kernel repo and build the smallest kernel core with default configuration for our arch
```bash
cd ./2_kernel/build
git clone https://github.com/torvalds/linux.git .
git checkout v5.9
make defconfig
make -j8 bzImage
```
Flashbuild will need the **bzImage** compressed binary generated by kernel compilation, for 64bit arch you will find it under ./2_kernel/src/arch/x86_64/boot/bzImage.
##### 2 Generate your initramfs
We use a simple Dockerfile and an init script to mount an initramfs after the kernel is loaded. These are the steps in a nutshell:
- pull base image
- install the packages that we want
- create some user
- cleanup filesystem
- overwrite inittab to initialize ttyS0 required by qemu
- add an init script to be called by the kernel
- that`s it !

Dockerfile:
```Dockerfile
# Alpine linux
# Base image --------------------------
# Alpine linux
FROM alpine:latest AS base
RUN apk update
# Add openrc service manager
RUN apk update openrc udev
# Create a group and user
RUN addgroup -S lucagroup && adduser -S luca -G lucagroup
# We set the login credentials
RUN echo "luca:luca" | chpasswd

# Patch fs ----------------------------
# Copy all fs to patching stage 
FROM alpine:latest
WORKDIR /fs
COPY --from=base / .
# Remove bogus /dev and /etc/mtab
RUN rm -rf dev etc/mtab tmp
# Wipe fstab
RUN echo > etc/fstab
# Add init script
ADD ./src/init init
# Add inittab file
ADD ./src/inittab etc/inittab
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
Inittab file:
```bash
# /etc/inittab
::sysinit:/sbin/openrc sysinit
::sysinit:/sbin/openrc boot
::wait:/sbin/openrc default
# Set up a couple of getty's
tty1::respawn:/sbin/getty 38400 tty1
# Put a getty on the serial port
ttyS0::respawn:/sbin/getty -L ttyS0 115200 vt100
# Stuff to do for the 3-finger salute
::ctrlaltdel:/sbin/reboot
# Stuff to do before rebooting
::shutdown:/sbin/openrc shutdown
```
Generate initramfs compressed archive:
```bash
make -C ./3_initramfs/ initramfs
```
##### 4 Emulate
```bash
./emulate.sh
```

