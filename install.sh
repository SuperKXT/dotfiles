#!/usr/bin/env bash

############################
# This scripts installs applications and sets up development environment
############################

# shellcheck source=scripts/list-from-file.sh
source scripts/list-from-file.sh

# Check if curl is installed, if not install it
type -p curl >/dev/null || sudo apt install curl -y

# Install apt packages
echo
echo "Setting Up APT Packages..."
APT_PACKAGES="$(list_from_file lists/apt-packages.txt)"
for package in $APT_PACKAGES; do
	sudo apt install -y "$package"
done

# Install or update nvm
echo
echo "Setting Up NVM..."
./scripts/install-nvm.sh

# get npm packages to install
NPM_PACKAGES="$(list_from_file lists/npm-packages.txt)"

# Install nvm node versions
for version in lts/* node; do
	echo
	echo "Setupging Up Node Version: $version..."
	nvm install "$version" &&
		for package in $NPM_PACKAGES; do
			sudo apt install -y "$package"
		done &&
		corepack enable &&
		corepack prepare yarn@latest --activate &&
		corepack prepare pnpm@latest --activate
done
nvm alias lts/* default
nvm use default
source ~/.bashrc

# Install Deno
if ! command -v deno &>/dev/null; then
	echo
	echo "Installing Deno..."
	curl -fsSL https://deno.land/install.sh | sh
fi

# install gh cli
if ! command -v gh &>/dev/null; then
	echo
	echo "Installing GitHub CLI..."
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &&
		sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg &&
		echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
		sudo apt update &&
		sudo apt install gh -y &&
		gh extension install mislav/gh-license
fi

# install vs code
if ! command -v code &>/dev/null; then
	echo
	echo "Installing VS Code..."
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
	echo
	echo "Installing Postman"
	curl https://gist.githubusercontent.com/SanderTheDragon/1331397932abaa1d6fbbf63baed5f043/raw/postman-deb.sh | sh &&
		source ~/.bashrc
fi

# install insomnia
if ! command -v insomnia &>/dev/null; then
	echo
	echo "Installing Insomnia"
	wget "https://updates.insomnia.rest/downloads/ubuntu/latest?app=com.insomnia.app&source=website" -O ./insomnia.deb &&
		sudo apt install ./insomnia.deb &&
		rm ./insomnia.deb
fi

# install azure data studio
if ! command -v azuredatastudio &>/dev/null; then
	echo
	echo "Installing Azure Data Studio..."
	wget https://go.microsoft.com/fwlink/?linkid=2215528 -O ./aszure-data-studio.deb &&
		sudo apt install ./azure-data-studio.deb &&
		rm ./azure-data-studio.deb
fi

# install anydesk
read -p "Do you want to install AnyDesk (y/n)? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	echo
	echo "Installing AnyDesk..."
	wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | apt-key add - &&
		echo "deb http://deb.anydesk.com/ all main" >/etc/apt/sources.list.d/anydesk-stable.list &&
		sudo apt update &&
		sudo apt install anydesk

fi

# install mongodb compass
if ! command -v mongodb-compass &>/dev/null; then
	echo
	echo "Installing MongoDB Compass..."
	wget https://downloads.mongodb.com/compass/mongodb-compass_1.34.2_amd64.deb -O compass.deb &&
		sudo apt install ./compass.deb &&
		rm ./compass.deb
fi

# Install Dropbox
# TODO setup dropbox installation
xdg-open https://www.dropbox.com/install?os=lnx

# Setup Themes
scripts/install-themes.sh

# Setup Fonts
scripts/install-fonts.sh

# Setup Dotfiles
echo
echo "Creating symlinks for dotfiles..."
cp -rsTv ~/dotfiles/config ~/

# Install Completions
scripts/install-completions.sh

source ~/.bashrc
