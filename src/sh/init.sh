#!/bin/bash

# CyPatrina 1.1
# Deep-Fried Tables

# Update all packages
sudo apt update
sudo apt -y upgrade

# Install all these packages, whether it be for points, or for more efficient patching
sudo apt -y install python3 ufw gufw aptitude mlocate

# These are on separate lines to be easily commented out
sudo apt -y install fail2ban
sudo apt -y install libpam-cracklib

sudo apt -y install clamtk
freshclam

sudo passwd -l root
