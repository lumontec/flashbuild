#!/bin/bash

# Emulate with qemu
qemu-system-x86_64  \
  -initrd ./initramfs.cpio \
  -kernel ./vmlinuz \
  -m 2048 \
  -append "console=ttyS0 nokaslr" \
  -nographic \
  -cpu host \
  -enable-kvm 
