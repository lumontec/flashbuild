#!/bin/bash

# Emulate with qemu
qemu-system-x86_64  \
  -initrd 3_initramfs/initramfs.cpio.gz \
  -kernel 2_kernel/vmlinuz \
  -m 2048 \
  -append "console=ttyS0 nokaslr" \
  -nographic \
  -cpu host \
  -enable-kvm 
