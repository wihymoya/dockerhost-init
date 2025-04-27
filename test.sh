#!/bin/bash

# Disable stub resolver
sudo sed -r -i.orig 's/#?DNSStubListener=yes/DNSStubListener=no/g' /etc/systemd/resolved.conf

# Update symlink to point to /run/systemd/resolve/resolv.conf, which is automatically updated to follow the system's netplan
sudo sh -c 'rm /etc/resolv.conf && ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf'

# Restart systemd-resolved service
sudo systemctl restart systemd-resolved
# --------------------------------
