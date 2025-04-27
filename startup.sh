#!/bin/bash
# Remember to source this script:
# user@host:~$ . ./startup.sh
# OR
# user@host:~$ source ./startup.sh

# --------------------------------
# Git Credential Manager

# Configure $gpg_passphrase via active prompt
gpg_passphrase=$(read -sp "GPG Passphrase: " gpg_pw; echo $gpg_pw); echo ""

# Update package lists
sudo apt-get update

# Install required packages
sudo apt-get --yes install gpg pass 

# Add GCM vars to environment and /etc/profile.d/custom_env.sh
customenv_filepath="/etc/profile.d/custom_env.sh"
gcmcredstore_line="export GCM_CREDENTIAL_STORE=gpg"; $gcmcredstore_line
gpgtty_line="export GPG_TTY=$(tty)"; $gpgtty_line

sudo sh -c "echo $gcmcredstore_line >> $customenv_filepath"
sudo sh -c "echo $gpgtty_line >> $customenv_filepath"

# Create config file for GPG --generate-key. User the vars to update your UID
name_real="wylabs-admin"
name_comment="in dev"
name_email="admin@wylabs.net"

cat > config <<EOF
	Key-Type: RSA
	Key-Length: 4096
	Key-Usage: encrypt
	Subkey-Type: RSA
	Subkey-Length: 4096
	Name-Real: $name_real
	Name-Comment: $name_comment
	Name-Email: $name_email
	Expire-Date: 1y
	Passphrase: $gpg_passphrase
EOF

# Run gpg to generate key pair using config file
gpg --batch --generate-key config

# Initialize credential store
pass init "$name_real ($name_comment) <$name_email>"

# Unset vars
unset gpg_passphrase customenv_filepath gcmcredstore_line gpgtty_line name_real name_comment name_email

# Download latest GCM deb package
wget "https://github.com/git-ecosystem/git-credential-manager/releases/download/v2.6.1/gcm-linux_amd64.2.6.1.deb"

# Install GCM package
sudo dpkg -i gcm-linux_amd64.2.6.1.deb

# Remove GCM deb package
sudo rm gcm-linux_amd64.2.6.1.deb

# Configure GCM
git-credential-manager configure
# --------------------------------

# --------------------------------
# Docker

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

# --------------------------------
# Disable port 53 on host

# Disable stub resolver
sudo sed -r -i.orig 's/#?DNSStubListener=yes/DNSStubListener=no/g' /etc/systemd/resolved.conf

# Update symlink to point to /run/systemd/resolve/resolv.conf, which is automatically updated to follow the system's netplan
sudo sh -c 'rm /etc/resolv.conf && ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf'

# Restart systemd-resolved service
sudo systemctl restart systemd-resolved
# --------------------------------
