
# Base image ---------------------------
# 
# We download a basic debian image to copy
# our fs tree 
# 
FROM debian:stretch

RUN apt-get update && apt-get install -y \
      build-essential \
      systemd \
      udev

# Change password for root
RUN echo "root:root" | chpasswd

# Add init script
ADD ./src/init init
