#!/bin/sh


# Build the docker image
docker build -t flash_initramfs ./build

# Create the container if not exists
docker start flash_initramfs 2> /dev/null || docker run --name flash_initramfs flash_initramfs

# Compress docker fs as archive
docker export flash_initramfs > ./build/flash_initramfs.tar

# Extract archive inside fs directory
mkdir ./build/fs
tar -xvf ./build/flash_initramfs.tar -C ./build/fs

# Clean /dev folder
rm -rf ./build/fs/dev

# Install init script
cp ./init /build/fs

# Generate initramfs as cpio archive
pushd ./build/fs
find . -print0 \
    | cpio --null -ov --format=newc \
    | gzip -9 > ./build/initramfs.cpio.gz

