#!/usr/bin/env bash

# shellcheck source=latest-git-release.sh
source ~/dotfiles/scripts/latest-git-release.sh

GREEN='\e[32m'
NC='\e[0m'

echo -e "\n${GREEN}Setting Up Fonts...${NC}"

folder=~/.local/share/fonts

mkdir -p "$folder"
rm -f "${folder:?}/*"

tag="$(latest_git_release be5invis/iosevka)" &&
	version="${tag:1}" &&
	url_prefix="https://github.com/be5invis/iosevka/releases/download" &&
	name_prefix="super-ttc-sgr-iosevka" &&
	#
	echo -e "\n${GREEN}Downloading Iosevka Fixed Slab for coding...${NC}" &&
	wget -q --show-progress "$url_prefix/$tag/$name_prefix-fixed-slab-$version.zip" -O slab.zip &&
	unzip -qo "slab.zip" -d "$folder" "*.ttc" &&
	rm slab.zip &&
	#
	echo -e "\n${GREEN}Downloading Iosevka Term Slab for terminal...${NC}" &&
	wget -q --show-progress "$url_prefix/$tag/$name_prefix-term-slab-$version.zip" -O term.zip &&
	unzip -qo "term.zip" -d "$folder" "*.ttc" &&
	rm term.zip &&
	#
	echo -e "\n${GREEN}Downloading Fonts From Dropbox...${NC}" &&
	wget -q --show-progress https://www.dropbox.com/sh/w465f79zweowwug/AADBkyI1xyG4meCdGE2Oogkoa?dl=1 -O fonts.zip &&
	unzip -qqo "fonts.zip" -d "$folder" "*.ttf" "*.otf" &&
	rm ./*.zip &&
	sudo fc-cache -f
