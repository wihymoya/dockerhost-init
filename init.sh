#!/bin/bash
# --------------------------------
# REMEMBER TO DOT RUN THIS SCRIPT
# user@host:~$ source ./gcm.sh
# --------------------------------

# Git Credential Installer
# --------------------------------
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

# Create config file for GPG --generate-key
cat > config <<EOF
	Key-Type: RSA
	Key-Length: 4096
	Key-Usage: encrypt
	Subkey-Type: RSA
	Subkey-Length: 4096
	Name-Real: wylabs-admin
	Name-Comment: still in dev
  Name-Email: admin@wylabs.net
  Expire-Date: 1y
  Passphrase: $gpg_passphrase
EOF

# Run gpg to generate key pair using config file
gpg --batch --generate-key config

# Unset $gpg_passphrase
unset gpg_passphrase

# Initialize credential store
pass init "wylabs-admin (still in dev) <admin@wylabs.net>"

# Download latest GCM deb package
wget "https://github.com/git-ecosystem/git-credential-manager/releases/download/v2.6.1/gcm-linux_amd64.2.6.1.deb"

# Install GCM package
sudo dpkg -i gcm-linux_amd64.2.6.1.deb

# Remove GCM deb package
sudo rm gcm-linux_amd64.2.6.1.deb

# Configure GCM
git-credential-manager configure
# --------------------------------
