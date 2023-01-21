#!/usr/bin/env bash

############################
# This scripts installs applications and sets up development environment
############################

# shellcheck source=/dev/null

GREEN='\e[32m'
NC='\e[0m'

sudo chmod u+x scripts/list-git-release.sh

# Check if curl is installed, if not install it
type -p curl >/dev/null || sudo apt install curl -y

# Check if xargs is installed, if not install it
type -p xargs >/dev/null || sudo apt install xargs -y

# Install apt packages
echo -e "\n${GREEN}Setting Up APT Packages...${NC}"
xargs sudo apt install -y <lists/apt-packages.txt

# Install or update nvm
sudo chmod u+x ~/dotfiles/scripts/install-nvm.sh
./scripts/install-nvm.sh
source ~/.bashrc

# Install nvm node versions
for version in lts/* node; do
	echo -e "\n${GREEN}Setting Up Node Version: $version...${NC}"
	nvm install "$version" &&
		xargs npm install -g <lists/npm-packages.txt &&
		corepack enable &&
		corepack prepare yarn@stable --activate &&
		corepack prepare pnpm@latest --activate
done
nvm alias lts/* default
nvm use default
source ~/.bashrc

# Install Deno
if ! command -v deno &>/dev/null; then
	echo -e "\n${GREEN}Installing Deno...${NC}"
	curl -fsSL https://deno.land/install.sh | sh &&
		export DENO_INSTALL="$HOME/.deno" &&
		export PATH="$DENO_INSTALL/bin:$PATH"
fi

# install gh cli
if ! command -v gh &>/dev/null; then
	echo -e "\n${GREEN}Installing GitHub CLI...${NC}"
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &&
		sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg &&
		echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
		sudo apt update &&
		sudo apt install gh -y &&
		gh extension install mislav/gh-license
fi

# install vs code
if ! command -v code &>/dev/null; then
	echo -e "\n${GREEN}Installing VS Code...${NC}"
	sudo apt-get install wget gpg &&
		wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg &&
		sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg &&
		sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' &&
		rm -f packages.microsoft.gpg &&
		sudo apt install apt-transport-https &&
		sudo apt update &&
		sudo apt install code
fi

#install postman
if ! command -v postman &>/dev/null; then
	echo -e "\n${GREEN}Installing Postman...${NC}"
	curl https://gist.githubusercontent.com/SanderTheDragon/1331397932abaa1d6fbbf63baed5f043/raw/postman-deb.sh | sh &&
		source ~/.bashrc
fi

# install insomnia
if ! command -v insomnia &>/dev/null; then
	echo -e "\n${GREEN}Installing Insomnia...${NC}"
	wget -q --show-progress "https://updates.insomnia.rest/downloads/ubuntu/latest?app=com.insomnia.app&source=website" -O ./insomnia.deb &&
		sudo apt install ./insomnia.deb &&
		rm ./insomnia.deb
fi

# install azure data studio
if ! command -v azuredatastudio &>/dev/null; then
	echo -e "\n${GREEN}Installing Azure Data Studio...${NC}"
	wget -q --show-progress https://go.microsoft.com/fwlink/?linkid=2215528 -O ./aszure-data-studio.deb &&
		sudo apt install ./azure-data-studio.deb &&
		rm ./azure-data-studio.deb
fi

# install vivaldi
if ! command -v vivaldi &>/dev/null; then
	echo -e "\n${GREEN}Installing Vivaldi...${NC}"
	curl --silent https://vivaldi.com/download/archive/?platform=linux --stderr - |
		grep -o -m 1 https://downloads.vivaldi.com/stable/vivaldi-stable_[0-9.-]*_amd64.deb |
		xargs wget -q --show-progress -O ./vivaldi.deb &&
		sudo apt install ./vivaldi.deb &&
		rm ./vivaldi.deb
fi

# install anydesk
if ! command -v anydesk &>/dev/null; then
	echo
	read -p "Do you want to install AnyDesk (y/n)? " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		echo -e "\n${GREEN}Installing AnyDesk...${NC}"
		wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | apt-key add - &&
			echo "deb http://deb.anydesk.com/ all main" >/etc/apt/sources.list.d/anydesk-stable.list &&
			sudo apt update &&
			sudo apt install anydesk

	fi
fi

# install mongodb compass
if ! command -v mongodb-compass &>/dev/null; then
	echo -e "\n${GREEN}Installing MongoDB Compass...${NC}"
	repo="mongodb-js/compass" &&
		tag="$(latest_git_release "$repo")" &&
		version="${tag:1}" &&
		wget -q --show-progress "https://github.com/${repo}/releases/download/${tag}/mongodb-compass_${version}_amd64.deb" -O compass.deb &&
		sudo apt install -y -qq ./compass.deb &&
		rm ./compass.deb
fi

# Install Dropbox
# TODO setup dropbox installation
xdg-open https://www.dropbox.com/install?os=lnx

# Setup Themes
sudo chmod u+x scripts/install-themes.sh
scripts/install-themes.sh

# Setup Fonts
sudo chmod u+x scripts/install-fonts.sh
scripts/install-fonts.sh

# Setup Dotfiles
echo -e "\n${GREEN}Creating symlinks for dotfiles...${NC}"
cp -rsTvf ~/dotfiles/config ~/

# Install Completions
sudo chmod u+x scripts/install-completions.sh
scripts/install-completions.sh

source ~/.bashrc
