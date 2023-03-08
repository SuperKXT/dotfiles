#!/usr/bin/env bash

############################
# This scripts installs applications and sets up development environment
############################

# shellcheck source=/dev/null

GREEN='\e[32m'
NC='\e[0m'

# shellcheck source=scripts/latest-git-release.sh
source ~/dotfiles/scripts/latest-git-release.sh

# Check if curl is installed, if not install it
type -p curl >/dev/null || sudo apt install curl -y

# Check if xargs is installed, if not install it
type -p xargs >/dev/null || sudo apt install xargs -y

# Install apt packages
echo -e "\n${GREEN}Setting Up APT Packages...${NC}"
xargs sudo apt -qq install -y <lists/apt-packages.txt

# Install or update nvm
sudo chmod u+x ~/dotfiles/scripts/install-nvm.sh
./scripts/install-nvm.sh
export NVM_DIR="$HOME/.nvm" &&
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" &&                # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# Install nvm node versions
for version in lts/* node; do
	echo -e "\n${GREEN}Setting Up Node Version: $version...${NC}"
	nvm install "$version" &&
		xargs npm install -g <lists/npm-packages.txt &&
		corepack enable &&
		corepack prepare yarn@stable --activate &&
		corepack prepare pnpm@latest --activate
done
nvm alias lts/* default
nvm use default

# Install Deno
if ! command -v deno &>/dev/null; then
	echo -e "\n${GREEN}Installing Deno...${NC}"
	curl -fsSL https://deno.land/install.sh | sh &&
		export DENO_INSTALL="$HOME/.deno" &&
		export PATH="$DENO_INSTALL/bin:$PATH"
fi

# install gh cli
if ! command -v gh &>/dev/null; then
	echo -e "\n${GREEN}Installing GitHub CLI...${NC}"
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &&
		sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg &&
		echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
		sudo apt -qq update &&
		sudo apt -qq install -y gh &&
		gh extension install mislav/gh-license &&
		gh auth login -w -s admin:public_key
fi

# install vs code
if ! command -v code &>/dev/null; then
	echo -e "\n${GREEN}Installing VS Code...${NC}"
	sudo apt-get install wget gpg &&
		wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg &&
		sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg &&
		sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' &&
		rm -f packages.microsoft.gpg &&
		sudo apt -qq install -y apt-transport-https &&
		sudo apt -qq update &&
		sudo apt -qq install -y code
fi

# install remmina
if ! command -v remmina &>/dev/null; then
	echo -e "\n${GREEN}Installing Remmina...${NC}"
	sudo apt-add-repository ppa:remmina-ppa-team/remmina-next &&
		sudo apt update &&
		sudo apt install remmina remmina-plugin-rdp remmina-plugin-secret

fi

#install postman
if ! command -v postman &>/dev/null; then
	echo -e "\n${GREEN}Installing Postman...${NC}"
	curl https://gist.githubusercontent.com/SanderTheDragon/1331397932abaa1d6fbbf63baed5f043/raw/postman-deb.sh | sh
fi

# install obs studio
if ! command -v obs &>/dev/null; then
	echo -e "\n${GREEN}Installing OBS Studio...${NC}"
	sudo add-apt-repository ppa:obsproject/obs-studio
	sudo apt update
	sudo apt install ffmpeg obs-studio
fi

# install insomnia
if ! command -v insomnia &>/dev/null; then
	echo -e "\n${GREEN}Installing Insomnia...${NC}"
	wget -q --show-progress "https://updates.insomnia.rest/downloads/ubuntu/latest?app=com.insomnia.app&source=website" -O ./insomnia.deb &&
		sudo apt install ./insomnia.deb &&
		rm ./insomnia.deb
fi

# install azure data studio
if ! command -v azuredatastudio &>/dev/null; then
	echo -e "\n${GREEN}Installing Azure Data Studio...${NC}"
	wget -q --show-progress https://go.microsoft.com/fwlink/?linkid=2215528 -O ./aszure-data-studio.deb &&
		sudo apt -qq install -y ./azure-data-studio.deb &&
		rm ./azure-data-studio.deb
fi

# install vivaldi
if ! command -v vivaldi &>/dev/null; then
	echo -e "\n${GREEN}Installing Vivaldi...${NC}"
	curl --silent https://vivaldi.com/download/archive/?platform=linux --stderr - |
		grep -o -m 1 https://downloads.vivaldi.com/stable/vivaldi-stable_[0-9.-]*_amd64.deb |
		xargs wget -q --show-progress -O ./vivaldi.deb &&
		sudo apt -qq install -y ./vivaldi.deb &&
		rm ./vivaldi.deb
fi

# install anydesk
if ! command -v anydesk &>/dev/null; then
	echo
	read -p "Do you want to install AnyDesk (y/n)? " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		echo -e "\n${GREEN}Installing AnyDesk...${NC}"
		wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | apt-key add - &&
			echo "deb http://deb.anydesk.com/ all main" >/etc/apt/sources.list.d/anydesk-stable.list &&
			sudo -qq apt update &&
			sudo apt -qq install -y anydesk

	fi
fi

# install mongodb compass
if ! command -v mongodb-compass &>/dev/null; then
	echo -e "\n${GREEN}Installing MongoDB Compass...${NC}"
	repo="mongodb-js/compass" &&
		tag="$(latest_git_release "$repo")" &&
		version="${tag:1}" &&
		wget -q --show-progress "https://github.com/${repo}/releases/download/${tag}/mongodb-compass_${version}_amd64.deb" -O compass.deb &&
		sudo apt -qq install -y ./compass.deb &&
		rm ./compass.deb
fi

# install slack
if ! command -v slack &>/dev/null; then
	echo -e "\n${GREEN}Installing Slack...${NC}"
	version="$(curl --silent https://slack.com/downloads/linux --stderr - | grep -Po -m 1 "(?<=Version )[0-9.]*")" &&
		wget -q --show-progress "https://downloads.slack-edge.com/releases/linux/${version}/prod/x64/slack-desktop-${version}-amd64.deb" -O slack.deb &&
		sudo apt -qq install -y ./slack.deb &&
		rm ./slack.deb
fi

# install proton vpn cli
if ! command -v protonvpn-cli &>/dev/null; then
	echo -e "\n${GREEN}Installing Proton VPN CLI...${NC}"
	wget -q --show-progress https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.3_all.deb -O proton_repo.deb &&
		sudo apt install ./proton_repo.deb &&
		rm ./proton_repo.deb &&
		sudo apt update &&
		sudo apt install protonvpn-cli
fi

# Install Dropbox
# TODO install latest dropbox
if ! command -v dropbox &>/dev/null; then
	echo -e "\n${GREEN}Installing Dropbox...${NC}"
	wget -q --show-progress https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2020.03.04_amd64.deb -O dropbox.deb &&
		sudo apt -qq install -y ./dropbox.deb &&
		rm ./dropbox.deb
fi

# install foliate
if ! command -v com.github.johnfactotum.Foliate &>/dev/null; then
	echo -e "\n${GREEN}Installing Foliate...${NC}"
	repo="johnfactotum/foliate" &&
		tag="$(latest_git_release "$repo")" &&
		version="${tag:1}" &&
		wget -q --show-progress "https://github.com/${repo}/releases/download/${tag}/com.github.johnfactotum.foliate_${version}_all.deb" -O foliate.deb &&
		sudo apt -qq install -y ./foliate.deb &&
		rm ./foliate.deb
fi

xdg-open https://www.dropbox.com/install?os=lnx

# Setup Themes
sudo chmod u+x scripts/setup-config.sh
scripts/setup-config.sh

# Setup Fonts
sudo chmod u+x scripts/install-fonts.sh
scripts/install-fonts.sh

# Setup Dotfiles
echo -e "\n${GREEN}Creating symlinks for dotfiles...${NC}"
cp -rsTvf ~/dotfiles/dot ~/

# Install Completions
sudo chmod u+x scripts/install-completions.sh
scripts/install-completions.sh

source ~/.bashrc
