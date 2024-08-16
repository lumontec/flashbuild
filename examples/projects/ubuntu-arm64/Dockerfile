
# Base image ---------------------------
# 
# We download a basic ubuntu image to copy
# our fs tree 

FROM ubuntu:20.04 AS base
RUN  apt update 
RUN  apt -y upgrade 

# Install systemd init system
RUN  apt install -y systemd udev

# Change password for root
RUN echo "root:root" | chpasswd

# Add init script
ADD ./src/init init
