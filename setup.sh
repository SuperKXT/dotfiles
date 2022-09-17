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

source ~/.bashrc

# Install node lts
nvm install lts/*

NPM_PACKAGES="nodemon node-gyp npm-check electron eslint tldr serve create-react-app pm2 jsdoc electron-icon-builder ngrok yarn yarn-check eslint-plugin-jsdoc vsce typescript @svgr/cli expo-cli ngrok ts-node dotenv-vault npkill"

#install postman
curl https://gist.githubusercontent.com/SanderTheDragon/1331397932abaa1d6fbbf63baed5f043/raw/postman-deb.sh | sh

#install global npm modules for node lts
npm i -g $NPM_PACKAGES

# Install node latest
nvm install node

#install global npm modules for node lts
npm i -g $NPM_PACKAGES

nvm alias lts/* default
nvm use default

source ~/.bashrc
corepack enable yarn
