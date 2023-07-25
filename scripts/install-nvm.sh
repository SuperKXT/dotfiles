#!/usr/bin/env bash

# shellcheck source=latest-git-release.sh
source ~/dotfiles/scripts/latest-git-release.sh

GREEN='\e[32m'
NC='\e[0m'

echo -e "\n${GREEN}Setting Up NVM...${NC}"
version="$(latest_git_release "nvm-sh/nvm")"
curl --progress-bar -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$version/install.sh" | bash
