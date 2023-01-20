#!/bin/bash

# CyPatrina 1.1
# Deep-Fried Tables

# Update all packages
sudo apt update
sudo apt -y upgrade

# Install all these packages, whether it be for points, or for more efficient patching
sudo apt -y install python3 ufw gufw aptitude mlocate bum

# These are on separate lines to be easily commented out
sudo apt -y install fail2ban
sudo apt -y install libpam-cracklib

sudo apt -y install clamtk
freshclam

# Lock Root Account
sudo passwd -l root

# Disable USB/Firewire/Thunderbolt
echo 'install usb-storage /bin/true' >> /etc/modprobe.d/disable-usb-storage.conf
echo "blacklist firewire-core" >> /etc/modprobe.d/firewire.conf
echo "blacklist thunderbolt" >> /etc/modprobe.d/thunderbolt.conf

# No IP spoofing
grep -qF 'multi on' && sed 's/multi/nospoof/' || echo 'nospoof on' >> /etc/host.conf
