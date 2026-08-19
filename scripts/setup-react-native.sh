#!/usr/bin/env bash
# shellcheck source=/dev/null

# https://docs.expo.dev/get-started/set-up-your-environment
# https://waldon.blog/2017/11/07/installing-android-studio-on-pop_os-or-ubuntu/

GREEN='\e[32m'
NC='\e[0m'

# Install Android Studio
if ! dpkg -s android-studio &>/dev/null; then
	echo
	echo -e "\n${GREEN}Downloading Android Studio...${NC}"
	sudo add-apt-repository -y ppa:maarten-fonville/android-studio
	sudo apt -qq update
	sudo apt -qq install android-studio
fi

android_home="$HOME/Android/Sdk"
ndk_version="25.1.8937393"

# Install Android SDK
if [ ! -d "${android_home}/cmdline-tools/latest" ]; then
	echo
	echo -e "\n${GREEN}Installing Android SDK...${NC}"
	mkdir -p "${android_home}/cmdline-tools"
	# Check https://developer.android.com/studio#command-tools for newer versions
	wget -q --show-progress "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip" -O ./cmdline-tools.zip
	unzip -q ./cmdline-tools.zip -d "${android_home}/cmdline-tools"
	mv "${android_home}/cmdline-tools/cmdline-tools" "${android_home}/cmdline-tools/latest"
	rm ./cmdline-tools.zip

	export ANDROID_HOME="${android_home}"
	yes | "${android_home}/cmdline-tools/latest/bin/sdkmanager" --sdk_root="${android_home}" --licenses &>/dev/null
	"${android_home}/cmdline-tools/latest/bin/sdkmanager" --sdk_root="${android_home}" \
		"platform-tools" \
		"platforms;android-36" \
		"build-tools;36.0.0" \
		"emulator" \
		"ndk;${ndk_version}"
fi

# Setting up KVM
# https://help.ubuntu.com/community/KVM/Installation

echo
echo -e "\n${GREEN}Setting Up KVM Emulation...${NC}"
egrep -c '(vmx|svm)' /proc/cpuinfo
sudo kvm-ok
sudo apt -qq install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
sudo apt -qq install -y virt-manager
sudo adduser $(id -un) libvirt
sudo adduser $(id -un) kvm
virsh list --all
sudo apt -qq install -y virt-manager

echo
echo -e "\n${GREEN}Login again to enable KVM${NC}"

echo
echo -e "\n${GREEN}Complete the setup by following: https://docs.expo.dev/get-started/set-up-your-environment ${NC}"

# Installing Watchman
if ! command -v watchman &>/dev/null; then
	echo
	echo -e "\n${GREEN}Installing Watchman...${NC}"
	tag=$(curl -fsSL "https://api.github.com/repos/facebook/watchman/releases?per_page=20" |
		jq -r 'map(select(.assets[] | .name | test("linux\\.zip"))) | first | .tag_name')
	wget -q --show-progress "https://github.com/facebook/watchman/releases/download/${tag}/watchman-${tag}-linux.zip" -O ./watchman.zip
	unzip -q ./watchman.zip -d ./watchman-extracted
	watchman_dir=$(find ./watchman-extracted -mindepth 1 -maxdepth 1 -type d | head -1)
	sudo cp "${watchman_dir}/bin/watchman" /usr/local/bin/watchman
	sudo cp -r "${watchman_dir}/lib/." /usr/local/lib/
	sudo ldconfig
	echo '{ "min_acceptable_nice_value": 8 }' | sudo tee /etc/watchman.json > /dev/null
	rm -rf ./watchman.zip ./watchman-extracted
fi

# Installing scrcpy
if ! command -v scrcpy &>/dev/null; then
	echo
	echo -e "\n${GREEN}Installing scrcpy...${NC}"
	sudo apt -qq install -y scrcpy
fi
