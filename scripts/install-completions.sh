#!/usr/bin/env bash

################
# Completeions #
################

GREEN='\e[32m'
NC='\e[0m'
DIR=~/.config/bash-completion/completions

echo -e "\n${GREEN}Setting Up Completions...${NC}\n"

# Create bash-completion user directory
mkdir -p $DIR

echo -e "\n${GREEN}Copying from completions folder...${NC}"
cp -rsTvf ~/dotfiles/completions $DIR

echo -e "\n${GREEN}Add Docker Completions...${NC}"
curl --progress-bar https://raw.githubusercontent.com/docker/cli/master/contrib/completion/bash/docker -o $DIR/docker

echo -e "\n${GREEN}Add Docker-Compose Completions...${NC}"
curl --progress-bar https://raw.githubusercontent.com/docker/compose/master/contrib/completion/bash/docker-compose -o $DIR/docker-compose

echo -e "\n${GREEN}Add Git Completions...${NC}"
curl --progress-bar https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o $DIR/git

echo -e "\n${GREEN}Add Yarn Completions...${NC}"
curl --progress-bar https://raw.githubusercontent.com/dsifford/yarn-completion/master/yarn-completion.bash -o $DIR/yarn

echo -e "\n${GREEN}Adding NVM Completions...${NC}"
curl --progress-bar https://raw.githubusercontent.com/nvm-sh/nvm/master/bash_completion -o $DIR/nvm

echo -e "\n${GREEN}Adding NPM Completions...${NC}"
npm completion >$DIR/npm

echo -e "\n${GREEN}Adding Deno Completions...${NC}"
deno completions bash >$DIR/deno

echo -e "\n${GREEN}Adding Gitub CLI Completions...${NC}"
gh completion -s bash >$DIR/gh

echo -e "\n${GREEN}Adding ngrok Completions...${NC}"
ngrok completion >$DIR/npm

echo -e "\n${GREEN}Adding PNPM Completions...${NC}"
pnpm completion bash >$DIR/pnpm

pm2 completion install
