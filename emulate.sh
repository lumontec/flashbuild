#!/bin/bash

# Emulate with qemu
qemu-system-x86_64 \
  -kernel 2_kernel/arch/x86_64/boot/bzImage \
  -initrd 3_initramfs/initramfs.cpio.gz \
  -m 3048 \
  -nographic \
  -append "console=ttyS0 nokaslr" \
  -enable-kvm \
  -cpu host \
#  -s -S
