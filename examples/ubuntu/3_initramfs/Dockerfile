
# Base image ---------------------------
# 
# We download a basic ubuntu image to copy
# our fs and usermod files

FROM ubuntu:20.04 AS base
RUN  apt update 
RUN  apt -y upgrade 

# Install systemd init system
RUN  apt install -y systemd udev
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
