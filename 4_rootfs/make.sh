#!/bin/sh


# Build the docker image
docker build -t flash_rootfs ./build

# Create the container if not exists
docker start flash_rootfs 2> /dev/null || docker run --name flash_rootfs flash_rootfs

# Compress docker fs as archive
docker export flash_rootfs > ./build/flash_rootfs.tar

# Extract archive inside fs directory
mkdir ./build/fs
tar -xvf ./build/flash_rootfs.tar -C ./build/fs

# Clean /dev folder
rm -rf ./build/fs/dev

# Install init script
cp ./init /build/fs

# Generate initramfs as cpio archive
pushd ./build/fs
find . -print0 \
    | cpio --null -ov --format=newc \
    | gzip -9 > ./build/initramfs.cpio.gz

