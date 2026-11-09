#!/usr/bin/env bash

# Install Bitwarden: the CLI (updating it if a newer version is available) and the
# desktop app, then log the CLI in. Source this to keep BW_SESSION in the calling script.
# Usage `scripts/install-bitwarden.sh [--update-cli]`
# `--update-cli` only updates the CLI, without prompting to log in.

GREEN='\e[32m'
NC='\e[0m'

bw_bin="$HOME/.local/bin/bw"

# Uses the standalone binary, since Node and pnpm aren't on PATH during install.sh
install_bitwarden_cli() {
	local url="https://vault.bitwarden.com/download/?app=cli&platform=linux"
	local latest dir
	# The download redirects to a URL containing the file name, and so the version
	latest="$(curl -sIL -o /dev/null -w '%{url_effective}' "$url" | grep -oP 'bw-linux-\K[0-9.]+(?=\.zip)' | head -1)"
	if [ -x "$bw_bin" ] && [ "$("$bw_bin" --version)" = "$latest" ]; then
		return 0
	fi

	echo -e "\n${GREEN}Installing Bitwarden CLI...${NC}"
	dir="$(mktemp -d)"
	wget -q "$url" -O "${dir}/bw.zip" &&
		unzip -q "${dir}/bw.zip" -d "$dir" &&
		install -Dm755 "${dir}/bw" "$bw_bin" || {
		echo "Failed to download or install the Bitwarden CLI"
		rm -rf "$dir"
		return 1
	}
	rm -rf "$dir"
}

install_bitwarden_desktop() {
	if ! flatpak info com.bitwarden.desktop &>/dev/null; then
		echo -e "\n${GREEN}Installing Bitwarden Desktop...${NC}"
		flatpak install -y --noninteractive flathub com.bitwarden.desktop &>/dev/null
	fi
}

login_bitwarden_cli() {
	[ -x "$bw_bin" ] || return 0
	[ "$("$bw_bin" status | jq -r .status)" = "unauthenticated" ] || return 0
	echo -e "\n${GREEN}Logging in to Bitwarden...${NC}"
	BW_SESSION="$("$bw_bin" login --raw)" && export BW_SESSION
}

install_bitwarden_cli
if [ "${1:-}" != "--update-cli" ]; then
	install_bitwarden_desktop
	login_bitwarden_cli
fi
