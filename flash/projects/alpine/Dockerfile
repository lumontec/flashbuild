
# Base image --------------------------

# Alpine linux
FROM alpine:latest AS base
RUN apk update

# Add openrc service manager
RUN apk update
RUN apk add openrc eudev file

# Create a user with login shell
RUN addgroup -S usergroup && adduser -S -s /bin/sh user -G usergroup

# We set the login credentials
RUN echo "user:user" | chpasswd


# Patch fs ----------------------------

# Copy all fs to patching stage 
FROM alpine:latest
WORKDIR /fs
COPY --from=base / .

# Remove bogus /dev and /etc/mtab
RUN rm -rf dev etc/mtab tmp

# Wipe fstab
RUN echo > etc/fstab

# Add init script
ADD ./src/init init

# Add inittab file
ADD ./src/inittab etc/inittab











## Ubuntu example 
#FROM ubuntu:20.04
#RUN  apt update 
#RUN  apt -y upgrade 
#
## Install systemd
#RUN  echo "installing systemd udev"
#RUN  apt install -y systemd udev iputils-ping
#RUN echo "root:root" | chpasswd

## Install sysdig depends
#RUN apt install -y --no-install-recommends \
#	libelf-dev \
#	libgrpc-dev \
#	libgrpc++-dev
#
# Set working directory
#WORKDIR /home

# Copy executables folder
#ADD ./external/sysdig ./sysdig
#ADD ./external/test ./test
#RUN chmod +x ./sysdig/sysdig



## Debian example
#FROM debian:stretch
#
#RUN apt-get update && apt-get install -y \
#      build-essential \
#      systemd \
#      udev
#
#
