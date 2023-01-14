#!/usr/bin/env bash

# shellcheck source=latest-git-release.sh
source latest-git-release.sh

echo
echo "Setting Up Fonts..."

folder="$HOME/.local/share/fonts"

mkdir -p "$folder"
rm -f "${folder:?}/*"

echo "Installing Iosevka Fixed Slab for coding..."
echo "Installing Iosevka Term Slab for terminal..."
repo="be5invis/iosevka"
tag="$(latest_git_release $repo)"
version="${tag:1}"
url_prefix="https://github.com/$repo/releases/download"
name_prefix="super-ttc-sgr-iosevka"
if [ -n "$version" ]; then
	wget -q --show-progress "$url_prefix/$tag/$name_prefix-fixed-slab-$version.zip" -O slab.zip &&
		wget -q --show-progress "$url_prefix/$tag/$name_prefix-term-slab-$version.zip" -O term.zip &&
		unzip slab.zip -d "$folder" "*.ttc" &&
		unzip term.zip -d "$folder" "*.ttc" &&
		rm slab.zip term.zip
fi

echo
echo "Downloading Fonts From Dropbox..."
wget -q https://www.dropbox.com/sh/w465f79zweowwug/AADBkyI1xyG4meCdGE2Oogkoa?dl=1 -O fonts.zip &&
	unzip fonts.zip -d "$folder" "*.{otf,ttf}" &&
	rm fonts.zip

sudo fc-cache -f
