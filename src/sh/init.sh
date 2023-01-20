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

sudo echo 'auth required pam_tally2.so deny=5 onerr=fail unlock_time=1800' >> /etc/pam.d/common-auth
sudo apt -y install libpam-cracklib
sudo sed -i 's/\(pam_unix\.so.*\)$/\1 remember=5 minlen=8/' /etc/pam.d/common-password
sudo sed -i 's/\(pam_cracklib\.so.*\)$/\1 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1/' /etc/pam.d/common-password

sudo apt-get -y install auditd && auditctl -e 1
sudo apt-get -y install clamtk && freshclam

# Lock Root Account
sudo passwd -l root

# Disable USB/Firewire/Thunderbolt
sudo echo 'install usb-storage /bin/true' >> /etc/modprobe.d/disable-usb-storage.conf
sudo echo "blacklist firewire-core" >> /etc/modprobe.d/firewire.conf
sudo echo "blacklist thunderbolt" >> /etc/modprobe.d/thunderbolt.conf

# No IP spoofing
grep -qF 'multi on' && sed 's/multi/nospoof/' || sudo echo 'nospoof on' >> /etc/host.conf

# Login configs
sudo sed -i 's/PASS_MAX_DAYS.*$/PASS_MAX_DAYS 90/;s/PASS_MIN_DAYS.*$/PASS_MIN_DAYS 10/;s/PASS_WARN_AGE.*$/PASS_WARN_AGE 7/' /etc/login.defs

# Detect rootkits
sudo apt-get -y install chkrootkit rkhunter
sudo chkrootkit
sudo rkhunter --update
sudo rkhunter --check
