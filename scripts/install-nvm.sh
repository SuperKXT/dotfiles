#!/usr/bin/env bash

# shellcheck source=latest-git-release.sh
source ~/dotfiles/scripts/latest-git-release.sh

echo
echo "Setting Up NVM"
version="$(latest_git_release "nvm-sh/nvm")" &&
	curl --progress-bar -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$version/install.sh" | bash &&
	source ~/.bashrc
