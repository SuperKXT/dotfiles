#!/usr/bin/env bash

# Install fonts: custom fonts from Google Drive, and Iosevka (updating it if a newer release is available).
# Usage `scripts/install-fonts.sh [--update]`
# `--update` only updates fonts if Iosevka is already installed.

GREEN='\e[32m'
NC='\e[0m'

# shellcheck source=latest-git-release.sh
source ~/dotfiles/scripts/latest-git-release.sh

folder="$HOME/.local/share/fonts"
marker="$HOME/.local/state/dotfiles/iosevka-version"

[ ! -f "$folder/SGr-IosevkaTermSlab.ttc" ] && [ "${1:-}" = "--update" ] && exit 0
mkdir -p "$folder"

# Custom fonts, copying only new or changed files
if rclone listremotes 2>/dev/null | grep -qx 'gdrive:'; then
	rclone copy gdrive:fonts "$folder"
fi

# Install iosevka fonts
# Term Slab for Terminal Use
# Slab for Normal Use
repo="be5invis/Iosevka"
tag="$(latest_git_release "$repo" 2>/dev/null)"
version="${tag#v}"
url_prefix="https://github.com/$repo/releases/download"
name_prefix="SuperTTC-SGr-Iosevka"
if [ -z "$tag" ]; then
	echo "Failed to get the latest Iosevka release"
elif [ -f "$folder/SGr-IosevkaTermSlab.ttc" ] && [ "$(cat "$marker" 2>/dev/null)" = "$tag" ]; then
	echo "Iosevka ${version} is up to date"
else
	echo -e "\n${GREEN}Installing Iosevka ${version}...${NC}"
	dir="$(mktemp -d)"
	if wget -q --show-progress "$url_prefix/$tag/${name_prefix}FixedSlab-$version.zip" -O "$dir/slab.zip" &&
		wget -q --show-progress "$url_prefix/$tag/${name_prefix}TermSlab-$version.zip" -O "$dir/term.zip" &&
		unzip -oq "$dir/slab.zip" -d "$folder" "*.ttc" &&
		unzip -oq "$dir/term.zip" -d "$folder" "*.ttc"; then
		mkdir -p "$(dirname "$marker")"
		echo "$tag" >"$marker"
	else
		echo "Failed to download or install Iosevka"
	fi
	rm -rf "$dir"
fi

fc-cache -f "$folder" >/dev/null
