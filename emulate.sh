#!/bin/bash

## Emulate with qemu
#qemu-system-aarch64  \
#  -machine raspi3 \
#  -initrd 3_initramfs/initramfs.cpio.gz \
#  -kernel 2_kernel/src/arch/arm64/boot/Image \
#  -m 1000 \
#  -append "console=ttyS0 nokaslr" \
##  -nographic \
##  -cpu host \
##  -enable-kvm \
##  -s -S
##  -kernel /home/crash/Documents/local/sysdig-repo/kernvirt/2_kernel/arch/x86_64/boot/bzImage \
##  -kernel 2_kernel/src/arch/arm64/boot/Image
##  -kernel 2_kernel/src/arch/x86_64/boot/bzImage \

qemu-system-aarch64 \
  -kernel 2_kernel/src/arch/arm64/boot/Image \
  -initrd 3_initramfs/initramfs.cpio.gz \
  -m 2048 \
  -M virt \
  -cpu cortex-a53 \
  -smp 8 \
  -nographic \
  -serial mon:stdio \
  -append "rw console=ttyAMA0 loglevel=8 rootwait fsck.repair=yes memtest=1" \
  -no-reboot
