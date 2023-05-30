#! /usr/bin/bash

# How to use: sudo bash install-script.sh

# Install SSH trough web on port 4200

sudo apt install openssl shellinabox -y

# Install Firewall

apt install ufw -y

# Default ports
ufw allow 80
ufw allow 443
ufw allow 22
ufw allow 7001
ufw allow 9090
# SSH trough web
ufw allow 4200
# Webmin
ufw allow 10000
# Zabbix
ufw allow 10050
ufw allow 10051
ufw enable

# Install Watool script for automatic updates & weekly reboot

curl -s -L https://raw.githubusercontent.com/optimanetworks/onx/main/config/watool.sh | sudo bash -s -- --install
watool --config

# Update all packages
sudo apt update && sudo apt upgrade -y

# Run unattended-upgrade
# configuration files: 
# /etc/apt/apt.conf.d/20auto-upgrades

sudo unattended-upgrade