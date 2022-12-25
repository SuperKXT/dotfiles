#!/usr/bin/env bash
# shellcheck source=/dev/null
############################
# This scripts installs applications and sets up development environment
############################

# Install apt packages
sudo apt install build-essential direnv httpie bat tilix gcc make libssl-dev libreadline-dev zlib1g-dev libsqlite3-dev gnome-tweaks

# Install nvm
if ! command -v nvm &>/dev/null; then
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
fi

# Install git completion script
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash

NPM_PACKAGES="nodemon npm-check electron eslint tldr jsdoc ngrok eslint-plugin-jsdoc vsce typescript @svgr/cli expo-cli eas-cli ts-node dotenv-vault npkill stylelint stylelint-config-standard stylelint-config-standard-scss pm2"

#install postman
curl https://gist.githubusercontent.com/SanderTheDragon/1331397932abaa1d6fbbf63baed5f043/raw/postman-deb.sh | sh
source ~/.bashrc

# Install node lts
nvm install lts/*
source ~/.bashrc

#install global npm modules for node lts
npm i -g "$NPM_PACKAGES"
corepack enable
corepack prepare yarn@latest --activate
corepack prepare pnpm@latest --activate

# Install node latest
nvm install node
source ~/.bashrc

#install global npm modules for node lts
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
