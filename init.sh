#!/bin/bash

# --------------------------------
# Install git-credential-oauth

# --------------------------------

# --------------------------------
# Install Docker
# Remove old and conflicting packages
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Update package lists
sudo apt-get update

# Install required packages
sudo apt-get --yes install ca-certificates curl

# Create required directory and modify permissions
sudo install -m 0755 -d /etc/apt/keyrings

# Add Docker's official GPG key
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

# Modify permissions of the GPG key
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Set up the stable repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package lists again to include Docker's repository
sudo apt-get update

# Install docker engine
sudo apt-get --yes install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add current user to the docker group for sudo-less docker commands
sudo usermod -aG docker $USER

# Activate changes to groups
newgrp docker
# --------------------------------
