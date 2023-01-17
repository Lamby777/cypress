# CyPatrina 1.0 init script, probably gonna add more stuff soon

# Update all packages
sudo apt update
sudo apt -y upgrade

# Install all these packages, whether it be for points, or for more efficient patching
sudo apt -y install python3 ufw gufw aptitude mlocate
sudo apt install libpam-cracklib

sudo apt install clamtk
freshclam
