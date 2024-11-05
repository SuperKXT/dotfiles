#!/usr/bin/env bash

############################
# This scripts installs applications and sets up development environment
############################

# shellcheck source=/dev/null

GREEN='\e[32m'
NC='\e[0m'

# Fix date & time if incorrect
sudo hwclock -s

# shellcheck source=scripts/latest-git-release.sh
source ~/dotfiles/scripts/latest-git-release.sh

if [ "$EUID" -eq 0 ]; then
	echo "Don't run this script as root"
	exit
fi

# Check if curl is installed, if not install it
type -p curl >/dev/null || sudo apt install curl -y

# Check if xargs is installed, if not install it
type -p xargs >/dev/null || sudo apt install xargs -y

# Install apt packages
echo -e "\n${GREEN}Setting Up APT Packages...${NC}"
xargs sudo apt -qq install -y <lists/apt-packages.txt

# Install or update nvm
./scripts/install-nvm.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# Install nvm node versions
for version in lts/* node; do
	echo -e "\n${GREEN}Setting Up Node Version: $version...${NC}"
	nvm install "$version"
	xargs npm install -g <lists/npm-packages.txt
	corepack enable
	corepack prepare yarn@stable --activate
	corepack prepare pnpm@latest --activate
done
nvm alias lts/* default
nvm use default

# Install Deno
if ! command -v deno &>/dev/null; then
	echo -e "\n${GREEN}Installing Deno...${NC}"
	curl -fsSL https://deno.land/x/install/install.sh | sh
	export DENO_INSTALL="/home/superkxt/.deno"
	export PATH="$DENO_INSTALL/bin:$PATH"
fi

# install gh cli
if ! command -v gh &>/dev/null; then
	echo -e "\n${GREEN}Installing GitHub CLI...${NC}"
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
	sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
	sudo apt -qq update
	sudo apt -qq install -y gh
	gh extension install mislav/gh-license
	gh auth login -w -s admin:public_key
fi

# install vs code
if ! command -v code &>/dev/null; then
	echo -e "\n${GREEN}Installing VS Code...${NC}"
	sudo apt -qq install -y wget gpg
	wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
	sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
	sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
	rm -f packages.microsoft.gpg
	sudo apt -qq install -y apt-transport-https
	sudo apt -qq update
	sudo apt -qq install -y code
fi

# install remmina
if ! command -v remmina &>/dev/null; then
	echo -e "\n${GREEN}Installing Remmina...${NC}"
	sudo apt-add-repository ppa:remmina-ppa-team/remmina-next
	sudo apt update
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
	sudo add-apt-repository -y ppa:obsproject/obs-studio
	sudo apt update
	sudo apt install ffmpeg obs-studio
fi

# install azure data studio
if ! command -v azuredatastudio &>/dev/null; then
	echo -e "\n${GREEN}Installing Azure Data Studio...${NC}"
	wget -q --show-progress https://go.microsoft.com/fwlink/?linkid=2215528 -O ./azure-data-studio.deb
	sudo apt -qq install -y ./azure-data-studio.deb
	rm ./azure-data-studio.deb
fi

# install vivaldi
if ! command -v vivaldi &>/dev/null; then
	echo -e "\n${GREEN}Installing Vivaldi...${NC}"
	curl --silent https://vivaldi.com/download/archive/?platform=linux --stderr - |
		grep -o -m 1 https://downloads.vivaldi.com/stable/vivaldi-stable_[0-9.-]*_amd64.deb |
		xargs wget -q --show-progress -O ./vivaldi.deb
	sudo apt -qq install -y ./vivaldi.deb
	rm ./vivaldi.deb
fi

# install Chrome
if ! command -v google-chrome &>/dev/null; then
	echo -e "\n${GREEN}Installing Google Chrome...${NC}"
	wget -q --show-progress https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O ./chrome.deb
	sudo apt -qq install -y ./chrome.deb
	rm ./chrome.deb
fi

# install anydesk
if ! command -v anydesk &>/dev/null; then
	echo
	read -p "Do you want to install AnyDesk (y/n)? " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		echo -e "\n${GREEN}Installing AnyDesk...${NC}"
		curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/anydesk.gpg
		echo "deb http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list
		sudo apt -qq update
		sudo apt -qq install -y anydesk
	fi
fi

# install slack
if ! command -v slack &>/dev/null; then
	echo
	read -p "Do you want to install Slack (y/n)? " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		echo -e "\n${GREEN}Installing Slack...${NC}"
		version="$(curl --silent https://slack.com/downloads/linux --stderr - | grep -Po -m 1 "(?<=Version )[0-9.]*")"
		wget -q --show-progress "https://downloads.slack-edge.com/releases/linux/${version}/prod/x64/slack-desktop-${version}-amd64.deb" -O slack.deb
		sudo apt -qq install -y ./slack.deb
		rm ./slack.deb
	fi
fi

# install proton vpn
if ! command -v protonvpn-app &>/dev/null; then
	echo -e "\n${GREEN}Installing Proton VPN...${NC}"
	wget -q --show-progress https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.4_all.deb -O proton_repo.deb
	sudo dpkg -i ./proton_repo.deb
	rm ./proton_repo.deb
	sudo apt -qq update
	sudo apt -qq install proton-vpn-gnome-desktop
fi

# Install Dropbox
if ! command -v dropbox &>/dev/null; then
	echo -e "\n${GREEN}Installing Dropbox...${NC}"
	wget -q --show-progress "https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2020.03.04_amd64.deb" -O dropbox.deb
	sudo apt -qq install -y ./dropbox.deb
	rm ./dropbox.deb
fi

# install koodo
if ! command -v koodo-reader &>/dev/null; then
	echo -e "\n${GREEN}Installing Koodo Reader...${NC}"
	repo="koodo-reader/koodo-reader"
	tag="$(latest_git_release "$repo")"
	echo "Latest tag: ${tag}"
	version="${tag:1}"
	wget -q --show-progress "https://github.com/${repo}/releases/download/${tag}/Koodo.Reader-${version}-amd64.deb" -O koodo.deb
	sudo apt -qq install -y ./koodo.deb
	rm ./koodo.deb
fi

# intall ngrok
if ! command -v ngrok &>/dev/nulll; then
	echo -e "\n${GREEN}Installing ngrok...${NC}"
	curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
	echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
	sudo apt -qq update
	sudo apt -qq install -y ngrok
fi

# intall qBitTorrent
if ! command -v qbittorrent &>/dev/nulll; then
	echo -e "\n${GREEN}Installing qBitTorrent...${NC}"
	sudo add-apt-repository -y ppa:qbittorrent-team/qbittorrent-stable
	sudo apt -qq update
	sudo apt -qq install -y qbittorrent
fi

# install Spotify
if ! command -v spotify-client &>/dev/null; then
	echo
	echo -e "\n${GREEN}Installing Spotify...${NC}"
	curl -sS https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
	echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
	sudo apt -qq update
	sudo apt -qq install -y spotify-client
fi

# install onefetch
if ! command -v onefetch &>/dev/null; then
	echo -e "\n${GREEN}Installing onefetch...${NC}"
	sudo add-apt-repository -y ppa:o2sh/onefetch
	sudo apt -qq update
	sudo apt -qq install -y onefetch
fi

# install wine
if ! command -v wine &>/dev/null; then
	echo
	echo -e "\n${GREEN}Installing Wine...${NC}"
	sudo dpkg --add-architecture i386
	sudo mkdir -pm755 /etc/apt/keyrings
	sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
	sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources
	sudo apt -qq update
	sudo apt -qq install --install-recommends winehq-stable
fi

# install mono
if ! command -v mono &>/dev/null; then
	echo
	echo -e "\n${GREEN}Installing Mono...${NC}"
	sudo apt install ca-certificates gnupg
	sudo gpg --homedir /tmp --no-default-keyring --keyring /usr/share/keyrings/mono-official-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
	echo "deb [signed-by=/usr/share/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/ubuntu stable-focal main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
	sudo apt -qq update
	sudo apt -qq install mono-devel
fi

# install MS Teams
if ! command -v teams-for-linux &>/dev/null; then
	echo
	echo -e "\n${GREEN}Installing MS Teams...${NC}"
	repo="IsmaelMartinez/teams-for-linux"
	tag="$(latest_git_release "$repo")"
	echo "Latest tag: ${tag}"
	version="${tag:1}"
	wget -q --show-progress "https://github.com/${repo}/releases/download/${tag}/teams-for-linux_${version}_amd64.deb" -O teams.deb
	sudo apt -qq install -y ./teams.deb
	rm ./teams.deb
fi

# Setup React Native Dev Environment
sudo chmod u+x scripts/setup-react-native.sh
scripts/setup-react-native.sh

# Setup Docker
sudo chmod u+x scripts/install-docker.sh
scripts/install-docker.sh

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
