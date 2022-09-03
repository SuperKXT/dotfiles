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

#install global npm modules for node lts
npm i -g nodemon node-gyp npm-check electron eslint tldr serve create-react-app pm2 jsdoc electron-icon-builder ngrok yarn yarn-check eslint-plugin-jsdoc vsce typescript @svgr/cli expo-cli ngrok ts-node dotenv-vault

# Install node latest
nvm install node

#install global npm modules for node lts
npm i -g nodemon node-gyp npm-check electron eslint tldr serve create-react-app pm2 jsdoc electron-icon-builder ngrok yarn yarn-check eslint-plugin-jsdoc vsce typescript @svgr/cli expo-cli ngrok ts-node dotenv-vault

nvm alias lts/* default
nvm use default

source ~/.bashrc
corepack enable yarn
