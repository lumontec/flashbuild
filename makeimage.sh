#!/bin/bash

# Sets the WSP to actual WORKSPACE PATH
WSP=$(pwd)

# Remove previous kernvirt-container
#docker container rm kernvirt-container 2> /dev/null

# Remove previous kernvirt image
#docker rmi kernvirt 2> /dev/null

# Build the docker image
docker build -t kernvirt $WSP/4_rootfs

# Create the container if not exists
docker start kernvirt-container 2> /dev/null || docker run --name kernvirt-container kernvirt

# Clean eventual /build/kernvirt directory
rm -rf $WSP/build

# Create /build/kernvirt directory
mkdir $WSP/build

# Compress docker fs as archive
docker export kernvirt-container > ./build/kernvirt-container.tar

# Extract archive inside fs directory
mkdir $WSP/build/fs
tar -xvf $WSP/build/kernvirt-container.tar -C ./build/fs

# Clean broken /dev devices
rm -rf $WSP/build/fs/dev

# Install init 
cp $WSP/3_initramfs/init $WSP/build/fs

# Generate initramfs image
pushd $WSP/build/fs
find . -print0 \
    | cpio --null -ov --format=newc \
    | gzip -9 > $WSP/3_initramfs/initramfs.cpio.gz

