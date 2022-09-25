#!/usr/bin/env bash
############################
# This scripts installs applications and sets up development environment
############################

# Install git completion script
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash

# Install apt packages
sudo apt install direnv httpie bat tilix gcc make libssl-dev libreadline-dev zlib1g-dev libsqlite3-dev gnome-tweaks

# Install nvm and node 16
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

NPM_PACKAGES="nodemon npm-check electron eslint tldr jsdoc ngrok eslint-plugin-jsdoc vsce typescript @svgr/cli expo-cli ts-node dotenv-vault npkill stylelint stylelint-config-standard stylelint-config-standard-scss"

#install postman
curl https://gist.githubusercontent.com/SanderTheDragon/1331397932abaa1d6fbbf63baed5f043/raw/postman-deb.sh | sh
source ~/.bashrc

# Install node lts
nvm install lts/*
source ~/.bashrc

#install global npm modules for node lts
npm i -g $NPM_PACKAGES
corepack enable
corepack prepare pnpm@latest --activate

# Install node latest
nvm install node
source ~/.bashrc

#install global npm modules for node lts
npm i -g $NPM_PACKAGES
corepack enable
corepack prepare pnpm@latest --activate

nvm alias lts/* default
nvm use default

source ~/.bashrc
