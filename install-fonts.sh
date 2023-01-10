#!/usr/bin/env bash

get_latest_release() {
	curl --progress-bar "https://api.github.com/repos/$1/releases/latest" |
		grep '"tag_name":' |
		sed -E 's/.*"([^"]+)".*/\1/'
}

folder="$HOME/.local/share/fonts"
repo="be5invis/iosevka"
tag="$(get_latest_release $repo)"
version="${tag:1}"
url_prefix="https://github.com/$repo/releases/download"
name_prefix="super-ttc-sgr-iosevka"
if [ -n "$version" ]; then
	wget -q --show-progress "$url_prefix/$tag/$name_prefix-fixed-slab-$version.zip" -O slab.zip &&
		wget -q --show-progress "$url_prefix/$tag/$name_prefix-term-slab-$version.zip" -O term.zip &&
		tar xvf slab.zip --directory "$folder" --wildcards "*.ttc" &&
		tar xvf term.zip --directory "$folder" --wildcards "*.ttc" &&
		rm slab.zip term.zip
fi

# wget -q https://www.dropbox.com/sh/w465f79zweowwug/AADBkyI1xyG4meCdGE2Oogkoa?dl=1 -O fonts.zip &&
# 	tar xvf fonts.zip --directory $font_folder --wildcards "*.[otf|ttf]" &&
# 	rm fonts.zip

# sudo fc-cache -f
