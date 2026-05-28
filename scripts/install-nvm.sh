#!/usr/bin/env bash

# shellcheck source=latest-git-release.sh
source ~/dotfiles/scripts/latest-git-release.sh

GREEN='\e[32m'
NC='\e[0m'

echo -e "\n${GREEN}Setting Up NVM...${NC}"
[ -d "$HOME/.nvm" ] && git -C "$HOME/.nvm" remote set-url origin https://github.com/nvm-sh/nvm.git
version="$(latest_git_release "nvm-sh/nvm")"
curl --progress-bar -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$version/install.sh" | bash
