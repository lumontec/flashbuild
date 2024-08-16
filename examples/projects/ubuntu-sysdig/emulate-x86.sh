#!/bin/bash

# Emulate with qemu
qemu-system-x86_64  \
  -initrd 3_initramfs/initramfs.cpio \
  -kernel ~/vmlinuz.old \
  -m 2048 \
  -append "console=ttyS0 nokaslr" \
  -nographic \
  -cpu host \
  -enable-kvm \
#  -s -S
#  -kernel 2_kernel/src/arch/arm64/boot/Image
#  -kernel 2_kernel/src/arch/x86_64/boot/bzImage \
#  -kernel /home/crash/Documents/local/sysdig-repo/kernvirt/2_kernel/arch/x86_64/boot/bzImage \
