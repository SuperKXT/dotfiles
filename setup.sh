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

# Install apt packages
PACKAGES="$(list_from_file ./packages.txt)"
sudo apt install "$PACKAGES"

# Install nvm
if ! command -v nvm &>/dev/null; then
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
fi

# Install git completion script
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash

#install postman
curl https://gist.githubusercontent.com/SanderTheDragon/1331397932abaa1d6fbbf63baed5f043/raw/postman-deb.sh | sh
source ~/.bashrc

# get npm packages to install
NPM_PACKAGES="$(list_from_file ./npm-packages.txt)"

# Install node lts
nvm install lts/*
source ~/.bashrc
npm i -g "$NPM_PACKAGES"
corepack enable
corepack prepare yarn@latest --activate
corepack prepare pnpm@latest --activate

# Install node latest
nvm install node
source ~/.bashrc
npm i -g "$NPM_PACKAGES"
corepack enable
corepack prepare yarn@latest --activate
corepack prepare pnpm@latest --activate

nvm alias lts/* default
nvm use default

source ~/.bashrc

# Install Deno
if ! command -v deno &>/dev/null; then
	curl -fsSL https://deno.land/install.sh | sh
fi

deno completions bash >/usr/local/etc/bash_completion.d/deno.bash
source /usr/local/etc/bash_completion.d/deno.bash
