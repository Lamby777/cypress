#!/bin/bash

# CyPatrina 1.2

# Enforce correct permissions on auth stuff
chmod 644 /etc/passwd
chmod 600 /etc/shadow
chmod 644 /etc/group
chmod 600 /etc/gshadow

# Lock Root Account
passwd -l root

# No IP spoofing
grep -qF 'multi on' && sed 's/multi/nospoof/' || echo 'nospoof on' >> /etc/host.conf

# Login configs
sed -i 's/PASS_MAX_DAYS.*$/PASS_MAX_DAYS 90/;s/PASS_MIN_DAYS.*$/PASS_MIN_DAYS 10/;s/PASS_WARN_AGE.*$/PASS_WARN_AGE 7/' /etc/login.defs


echo "Which distro are you using?"
select yn in "Yes" "No"; do
	case $yn in
		Ubuntu ) ubuntuFn;;
		Fedora ) fedoraFn;;
	esac
done

function ubuntuFn {
	# Update all packages
	apt update
	apt -y upgrade

	# Install all these packages, whether it be for points, or for more efficient patching
	apt -y install python3 ufw gufw aptitude mlocate

	# These are on separate lines to be easily commented out
	apt -y install fail2ban

	echo 'auth required pam_tally2.so deny=5 onerr=fail unlock_time=1800' >> /etc/pam.d/common-auth
	apt -y install libpam-cracklib
	sed -i 's/\(pam_unix\.so.*\)$/\1 remember=5 minlen=8/' /etc/pam.d/common-password
	sed -i 's/\(pam_cracklib\.so.*\)$/\1 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1/' /etc/pam.d/common-password

	apt-get -y install auditd && auditctl -e 1
	apt-get -y install clamtk && freshclam

	# Disable USB/Firewire/Thunderbolt
	echo 'install usb-storage /bin/true' >> /etc/modprobe.d/disable-usb-storage.conf
	echo "blacklist firewire-core" >> /etc/modprobe.d/firewire.conf
	echo "blacklist thunderbolt" >> /etc/modprobe.d/thunderbolt.conf

	# Detect rootkits
	apt-get -y install chkrootkit rkhunter
	chkrootkit
	rkhunter --update
	rkhunter --check
}

function fedoraFn {
	# Install UFW
	dnf install ufw
	systemctl stop firewalld
	systemctl disable firewalld
	systemctl enable ufwd
	systemctl start ufwd
}
