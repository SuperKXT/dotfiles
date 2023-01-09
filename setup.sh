#!/usr/bin/env bash
# shellcheck source=/dev/null
############################
# This scripts installs applications and sets up development environment
############################

# Usage `get-latest-release "action/runner"`
get-latest-release() {
	curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
		grep '"tag_name":' |                                             # Get tag line
		sed -E 's/.*"([^"]+)".*/\1/'                                     # Pluck JSON value
}

list_from_file() {
	local packages=''
	while IFS= read -r line; do
		packages+=" $line"
	done <"$1"
	echo "$packages"
}

type -p curl >/dev/null || sudo apt install curl -y

# Install apt packages
PACKAGES="$(list_from_file ./packages.txt)"
sudo apt install "$PACKAGES"

# Install nvm
if ! command -v nvm &>/dev/null; then
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
fi

# Install git completion script
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash

# get npm packages to install
NPM_PACKAGES="$(list_from_file ./npm-packages.txt)"

# Install node lts
nvm install lts/* &&
	npm i -g "$NPM_PACKAGES" &&
	corepack enable &&
	corepack prepare yarn@latest --activate &&
	corepack prepare pnpm@latest --activate

# Install node latest
nvm install node &&
	npm i -g "$NPM_PACKAGES" &&
	corepack enable &&
	corepack prepare yarn@latest --activate &&
	corepack prepare pnpm@latest --activate

nvm alias lts/* default
nvm use default

source ~/.bashrc

# Install Deno
if ! command -v deno &>/dev/null; then
	curl -fsSL https://deno.land/install.sh | sh
fi

deno completions bash >/usr/local/etc/bash_completion.d/deno.bash &&
	source /usr/local/etc/bash_completion.d/deno.bash

# install gh cli
if ! command -v gh &>/dev/null; then
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &&
		sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg &&
		echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
		sudo apt update &&
		sudo apt install gh -y &&
		gh extension install mislav/gh-license
fi

# install vs code
if ! command -v code &>/dev/null; then
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
	curl https://gist.githubusercontent.com/SanderTheDragon/1331397932abaa1d6fbbf63baed5f043/raw/postman-deb.sh | sh &&
		source ~/.bashrc
fi

# install insomnia
if ! command -v insomnia &>/dev/null; then
	wget "https://updates.insomnia.rest/downloads/ubuntu/latest?app=com.insomnia.app&source=website" -O ./insomnia.deb &&
		sudo apt install ./insomnia.deb &&
		rm ./insomnia.deb
fi

# install azure data studio
if ! command -v azuredatastudio &>/dev/null; then
	wget https://go.microsoft.com/fwlink/?linkid=2215528 -O ./aszure-data-studio.deb &&
		sudo apt install ./azure-data-studio.deb &&
		rm ./azure-data-studio.deb
fi

# install anydesk
read -p "Do you want to install AnyDesk (y/n)? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | apt-key add - &&
		echo "deb http://deb.anydesk.com/ all main" >/etc/apt/sources.list.d/anydesk-stable.list &&
		sudo apt update &&
		sudo apt install anydesk

fi

# install mongodb compass
if ! command -v mongodb-compass &>/dev/null; then
	wgeet https://downloads.mongodb.com/compass/mongodb-compass_1.34.2_amd64.deb -O compass.deb &&
		sudo apt install ./compass.deb &&
		rm ./compass.deb
fi

# install dropbox
xdg-open https://www.dropbox.com/install?os=lnx

# install orchis theme
git clone https://github.com/vinceliuice/Orchis-theme orchis &&
	cd orchis &&
	source ./install.sh -t red -c light -s compact -l --round 0px --tweaks compact primary &&
	cd .. &&
	rm -rf orchis

# install tela icon theme
git clone https://github.com/vinceliuice/Tela-icon-theme tela &&
	source ./install.sh &&
	cd .. &&
	rm -rf tela red

# install iosevka fonts
iosveka_repo="be5invis/Iosevka"
iosevka_version=get-latest-release $iosveka_repo &&
	wget "https://github.com/$iosveka_repo/releases/download/v$iosevka_version/super-ttc-iosevka-fixed-slab-$iosevka_version.zip" -O slab.zip &&
	wget "https://github.com/$iosveka_repo/releases/download/v$iosevka_version/super-ttc-iosevka-term-slab-$iosevka_version.zip" -O slab.zip

# setup dotfiles
source ./install.sh

# setup os fonts and icons and themes and shit
