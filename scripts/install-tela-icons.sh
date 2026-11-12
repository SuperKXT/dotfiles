#!/usr/bin/env bash

# Install the purple Tela icon theme, or update it if the repo has new commits.
# Usage `scripts/install-tela-icons.sh [--update]`
# `--update` only updates the theme if it's already installed.

GREEN='\e[32m'
NC='\e[0m'

repo_url="https://github.com/vinceliuice/Tela-icon-theme"
theme_dir="$HOME/.local/share/icons/Tela-purple"
marker="$HOME/.local/state/dotfiles/tela-icons-commit"

[ ! -d "$theme_dir" ] && [ "${1:-}" = "--update" ] && exit 0

latest="$(git ls-remote "$repo_url" HEAD | cut -f1)"
if [ -z "$latest" ]; then
	echo "Failed to get the latest Tela icon theme commit"
	exit 1
fi
if [ -d "$theme_dir" ] && [ "$(cat "$marker" 2>/dev/null)" = "$latest" ]; then
	echo "Tela icon theme is up to date"
	exit 0
fi

echo -e "\n${GREEN}Installing Tela Icon Theme...${NC}"
dir="$(mktemp -d)"
git clone -q --depth 1 "$repo_url" "$dir" &&
	(cd "$dir" && ./install.sh purple) || {
	echo "Failed to install the Tela icon theme"
	rm -rf "$dir"
	exit 1
}
rm -rf "$dir"
mkdir -p "$(dirname "$marker")"
echo "$latest" >"$marker"
