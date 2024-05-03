#!/usr/bin/env bash
# shellcheck source=/dev/null

# https://reactnative.dev/docs/environment-setup?guide=native
# https://waldon.blog/2017/11/07/installing-android-studio-on-pop_os-or-ubuntu/

GREEN='\e[32m'
NC='\e[0m'

# Install Android Studio
if ! command -v android-studio &>/dev/null; then
	echo
	echo -e "\n${GREEN}Downloading Android Studio...${NC}"
	sudo add-apt-repository -y ppa:maarten-fonville/android-studio
	sudo apt -qq update
	sudo apt -qq install android-studio
fi

# Setting up KVM
# https://help.ubuntu.com/community/KVM/Installation

echo
echo -e "\n${GREEN}Setting Up KVM Emulation...${NC}"
egrep -c '(vmx|svm)' /proc/cpuinfo
sudo kvm-ok
sudo apt -qq install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
sudo apt -qq install -y virt-manager
udo adduser $(id-un) libvirt
sudo adduser $(id-un) kvm
virsh list --all
sudo apt -qq install -y virt-manager

echo
echo -e "\n${GREEN}Login again to enable KVM${NC}"

echo
echo -e "\n${GREEN}Complete the setup by following: https://reactnative.dev/docs/environment-setup?guide=native${NC}"

# Installing Watchman
if ! command -v watchman &>/dev/null; then
	echo
	echo -e "\n${GREEN}Installing Watchman...${NC}"
	git clone https://github.com/facebook/watchman
	cd watchman || exit
	sudo ./install-system-packages.sh
	./autogen.sh
	cd ..
	rm -rf ./watchman
fi
