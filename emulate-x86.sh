#!/bin/bash

# Emulate with qemu
qemu-system-x86_64  \
  -initrd ./workspace/initramfs.cpio.gz \
  -kernel ./workspace/vmlinuz \
  -m 2048 \
  -append "console=ttyS0 nokaslr" \
  -nographic \
  -cpu host \
  -net nic,model=virtio \
  -L /usr/share/seavgabios \
  -enable-kvm 

