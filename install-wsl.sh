#!/usr/bin/env bash

############################
# This scripts installs applications and sets up development environment for WSL (Ubuntu)
############################

# shellcheck source=/dev/null

GREEN='\e[32m'
NC='\e[0m'

# shellcheck source=scripts/latest-git-release.sh
source ~/dotfiles/scripts/latest-git-release.sh

if [ "$EUID" -eq 0 ]; then
	echo "Don't run this script as root"
	exit
fi

# Check if curl is installed, if not install it
type -p curl >/dev/null || sudo apt -qq install -y curl

if [[ -n "$WSL_DISTRO_NAME" ]]; then
	type -p wslview >/dev/null || sudo apt -qq install -y wslu
	export BROWSER=wslview
fi

# Check if xargs is installed, if not install it
type -p xargs >/dev/null || sudo apt -qq install -y xargs

# Enable 32-bit architecture for Android SDK emulator support
sudo dpkg --add-architecture i386
sudo apt -qq update &>/dev/null

# Install apt packages
echo -e "\n${GREEN}Setting Up APT Packages...${NC}"
xargs sudo apt -qq install -y <lists/apt-packages.txt

# Install or update nvm
./scripts/install-nvm.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# Install nvm node versions
for version in lts/*; do
	echo -e "\n${GREEN}Setting Up Node Version: $version...${NC}"
	nvm install "$version" &>/dev/null
	xargs npm install -g --silent <lists/npm-packages.txt
	corepack enable &>/dev/null
	corepack prepare yarn@stable --activate &>/dev/null
	corepack prepare pnpm@latest --activate &>/dev/null
done
nvm alias lts/* default &>/dev/null
nvm use default &>/dev/null

# install claude code
if ! command -v claude &>/dev/null; then
	echo -e "\n${GREEN}Installing Claude Code...${NC}"
	curl -fsSL https://claude.ai/install.sh | bash &>/dev/null
	echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
	claude auth login
fi

if [[ -z "$WSL_DISTRO_NAME" ]]; then
	echo -e "\n${GREEN}Setting Up UFW firewall...${NC}"
	sudo ufw enable
	sudo ufw allow ssh
	sudo ufw allow 3000:3050/tcp
	sudo ufw allow 4000:4020/tcp
	sudo ufw allow 5000:5020/tcp
	sudo ufw allow 8000:8010/tcp
	# Expo Go
	sudo ufw allow 8081/tcp
fi

# Update max number of allowed file watchers
echo -e "\n${GREEN}Configuring SysCTL...${NC}"
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

# install gh cli
if ! command -v gh &>/dev/null; then
	echo -e "\n${GREEN}Installing GitHub CLI...${NC}"
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg status=none
	sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
	sudo apt -qq update &>/dev/null
	sudo apt -qq install -y gh
fi

if [ ! -f "$HOME/.ssh/config" ]; then
	echo -e "\n${GREEN}Setting Up SSH config...${NC}"
	gh extension install mislav/gh-license &>/dev/null
	gh auth login -p https -s admin:public_key,admin:ssh_signing_key -w
	gh config set git_protocol ssh
	while [[ -z "$ssh_key_label" ]]; do
		read -rp "Enter a label for the SSH key: " ssh_key_label
	done
	ssh-keygen -t ed25519 -C "superkxt@outlook.com" -f ~/.ssh/id_github -N ""
	eval "$(ssh-agent -s)"
	ssh-add ~/.ssh/id_github
	cp ~/dotfiles/config/.ssh/* ~/.ssh/
	echo -e "\n${GREEN}Authenticating gh cli with ssh key...${NC}"
	echo -e "\n${GREEN}Adding SSH key...${NC}"
	gh ssh-key add ~/.ssh/id_github.pub --title "$ssh_key_label"
	echo -e "\n${GREEN}Adding SSH signing key...${NC}"
	gh ssh-key add ~/.ssh/id_github.pub --type signing --title "${ssh_key_label}-signing"
fi


# Install Deno
if ! command -v deno &>/dev/null; then
	echo -e "\n${GREEN}Installing Deno...${NC}"
	curl -fsSL https://deno.land/x/install/install.sh | sh &>/dev/null
	export DENO_INSTALL="/home/superkxt/.deno"
	export PATH="$DENO_INSTALL/bin:$PATH"
fi

# intall ngrok
if ! command -v ngrok &>/dev/null; then
	echo -e "\n${GREEN}Installing ngrok...${NC}"
	curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
	echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list >/dev/null
	sudo apt -qq update &>/dev/null
	sudo apt -qq install -y ngrok
fi

# install onefetch
if ! command -v onefetch &>/dev/null; then
	echo -e "\n${GREEN}Installing onefetch...${NC}"
	sudo add-apt-repository -y ppa:o2sh/onefetch &>/dev/null
	sudo apt -qq update &>/dev/null
	sudo apt -qq install -y onefetch
fi

# Install Turso CLI
curl -sSfL https://get.tur.so/install.sh | bash &>/dev/null

# Setup React Native Dev Environment
sudo chmod u+x scripts/setup-react-native.sh
scripts/setup-react-native.sh

# Setup Docker
sudo chmod u+x scripts/install-docker.sh
scripts/install-docker.sh

# Setup Dotfiles
echo -e "\n${GREEN}Creating symlinks for dotfiles...${NC}"
cp -rsTvf ~/dotfiles/dot ~/

# Install Completions
sudo chmod u+x scripts/install-completions.sh
scripts/install-completions.sh

source ~/.bashrc
