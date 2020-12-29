
# Base image ---------------------------
# 
# We download a basic debian image to copy
# our fs tree 
# 
FROM debian:stretch AS base

RUN apt-get update && apt-get install -y \
      build-essential \
      systemd \
      udev

# Change password for root
RUN echo "root:root" | chpasswd

# Patch fs ----------------------------
# 
# We install a basic /init script that launches
# systemd after being invoked by the kernel

# Copy all fs workdir where we patch our fs 
FROM alpine:latest
WORKDIR /fs
COPY --from=base / .

# Add init script
ADD ./src/init init
