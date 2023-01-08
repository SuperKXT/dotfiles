#!/usr/bin/env bash
# shellcheck source=/dev/null
############################
# This scripts installs applications and sets up development environment
############################

list_from_file() {
	file='./packages.txt'
	local packages=''
	while IFS= read -r line; do
		packages+=" $line"
	done <$file
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
	source ~/.bashrc &&
	npm i -g "$NPM_PACKAGES" &&
	corepack enable &&
	corepack prepare yarn@latest --activate &&
	corepack prepare pnpm@latest --activate

# Install node latest
nvm install node &&
	source ~/.bashrc &&
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
wget https://go.microsoft.com/fwlink/?linkid=2215528 -O ./aszure-data-studio.deb &&
	sudo apt install ./azure-data-studio.deb &&
	rm ./azure-data-studio.deb

# install anydesk
read -p "Do you want to install AnyDesk (y/n)? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | apt-key add - &&
		echo "deb http://deb.anydesk.com/ all main" >/etc/apt/sources.list.d/anydesk-stable.list &&
		sudo apt update &&
		sudo apt install anydesk

fi

# install dropbox
xdg-open https://www.dropbox.com/install?os=lnx
