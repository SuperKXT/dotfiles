#!/usr/bin/env bash

# Install the Android SDK packages Expo needs, or update every installed SDK package.
# Usage `scripts/install-android-sdk.sh [--update]`
# `--update` only updates the SDK if it's already installed.

GREEN='\e[32m'
NC='\e[0m'

sdk="$HOME/Android/Sdk"
tools="$sdk/cmdline-tools"
android_cli="$tools/latest/bin/android"
ndk_version="25.1.8937393"

# The Android CLI (cmdline-tools 23+) replaces sdkmanager, and collects usage data unless told not to
android_sdk() {
	"$android_cli" --no-metrics --sdk="$sdk" sdk "$@"
}

# sdkmanager can't replace the copy it runs from, so it installs the new one into latest-2
move_new_tools_into_place() {
	if [ -d "$tools/latest-2" ]; then
		rm -rf "$tools/latest" && mv "$tools/latest-2" "$tools/latest"
	fi
}

if [ ! -d "$tools/latest" ]; then
	[ "${1:-}" = "--update" ] && exit 0
	echo -e "\n${GREEN}Installing Android SDK...${NC}"
	# Bootstrap with an older release, whose sdkmanager installs the latest command-line tools
	# Check https://developer.android.com/studio#command-tools for newer versions
	dir="$(mktemp -d)"
	wget -q --show-progress "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip" -O "$dir/cmdline-tools.zip" &&
		unzip -q "$dir/cmdline-tools.zip" -d "$dir" || {
		echo "Failed to download the Android command-line tools"
		rm -rf "$dir"
		exit 1
	}
	yes | "$dir/cmdline-tools/bin/sdkmanager" --sdk_root="$sdk" --licenses &>/dev/null
	"$dir/cmdline-tools/bin/sdkmanager" --sdk_root="$sdk" "cmdline-tools;latest"
	rm -rf "$dir"
	android_sdk install platform-tools platforms/android-36 build-tools/36.0.0 emulator "ndk/${ndk_version}"
	exit
fi

# Command-line tools from before the Android CLI are unpacked by hand and so never updated
if [ ! -x "$android_cli" ]; then
	echo -e "\n${GREEN}Updating Android command-line tools...${NC}"
	"$tools/latest/bin/sdkmanager" --sdk_root="$sdk" "cmdline-tools;latest"
	move_new_tools_into_place
fi

android_sdk update
move_new_tools_into_place
