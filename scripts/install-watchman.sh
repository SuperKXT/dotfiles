#!/usr/bin/env bash

# Install Watchman from its latest GitHub release, or update it if a newer release is available.
# Usage `scripts/install-watchman.sh [--update]`
# `--update` only updates Watchman if it's already installed.

GREEN='\e[32m'
NC='\e[0m'

current=""
command -v watchman &>/dev/null && current="$(watchman --version 2>/dev/null)"
[ -z "$current" ] && [ "${1:-}" = "--update" ] && exit 0

# Not every release has a Linux build, so take the newest one that does
tag="$(curl -fsSL "https://api.github.com/repos/facebook/watchman/releases?per_page=20" |
	jq -r 'map(select(.assets[] | .name | test("linux\\.zip"))) | first | .tag_name')"
if [ -z "$tag" ] || [ "$tag" = "null" ]; then
	echo "Failed to get the latest Watchman release"
	exit 1
fi

# Tags look like v2026.11.09.00 and `watchman --version` like 20261109.012849.0, so compare the dates
latest_date="$(tr -d 'v.' <<<"${tag:0:11}")"
if [ "${current:0:8}" = "$latest_date" ]; then
	echo "Watchman ${current} is up to date"
	exit 0
fi

echo -e "\n${GREEN}Installing Watchman ${tag}${current:+ (from ${current})}...${NC}"
dir="$(mktemp -d)"
wget -q --show-progress "https://github.com/facebook/watchman/releases/download/${tag}/watchman-${tag}-linux.zip" -O "${dir}/watchman.zip" &&
	unzip -q "${dir}/watchman.zip" -d "${dir}/extracted" || {
	echo "Failed to download Watchman"
	rm -rf "$dir"
	exit 1
}
watchman_dir="$(find "${dir}/extracted" -mindepth 1 -maxdepth 1 -type d | head -1)"
# Stop the running server so the next client starts the new version
[ -n "$current" ] && watchman shutdown-server &>/dev/null
sudo cp "${watchman_dir}/bin/watchman" /usr/local/bin/watchman
sudo cp -r "${watchman_dir}/lib/." /usr/local/lib/
sudo ldconfig
echo '{ "min_acceptable_nice_value": 8 }' | sudo tee /etc/watchman.json >/dev/null
rm -rf "$dir"
