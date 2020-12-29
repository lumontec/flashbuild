#!/bin/bash

# Emulate with qemu
qemu-system-x86_64 \
  -kernel /home/crash/Documents/local/sysdig-repo/kernvirt/2_kernel/arch/x86_64/boot/bzImage \
  -initrd 3_initramfs/initramfs.cpio.gz \
  -m 3048 \
  -enable-kvm \
  -cpu host \
  -append "console=ttyS0 nokaslr" \
  -nographic \
#  -s -S
#  -kernel 2_kernel/src/arch/x86_64/boot/bzImage \
#  -kernel 2_kernel/src/arch/x86_64/boot/bzImage \
