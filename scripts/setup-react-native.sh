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

	echo -e "\n${GREEN}Starting Android Studio Setup...${NC}"
	~/Applications/android-studio/bin/studio.sh
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
echo -e "\n${GREEN}Login again to enable KVM${NC}"

echo
echo -e "\n${GREEN}Install The Following From Android Studio SDK Manager:${NC}"
echo -e "\n${GREEN}Android SDK Platform 34${NC}"
echo -e "\n${GREEN}Intel x86 Atom_64 System Image${NC}"
