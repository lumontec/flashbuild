# Ubuntu example 
FROM ubuntu:20.04
RUN  apt update 
RUN  apt -y upgrade 

# Install systemd
RUN  echo "installing systemd udev"
RUN  apt install -y systemd udev
RUN echo "root:root" | chpasswd

# Install sysdig depends
RUN apt install -y --no-install-recommends \
	libelf-dev \
	libgrpc-dev \
	libgrpc++-dev


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

# Copy executables folder
ADD ./src/sysdig ./sysdig
RUN chmod +x ./sysdig/sysdig


