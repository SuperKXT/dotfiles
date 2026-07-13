#!/usr/bin/env bash

############################
# This scripts installs applications and sets up development environment
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

# Run base install
./install-wsl.sh

# Install gear-lever (AppImage manager)
if ! flatpak info it.mijorus.gearlever &>/dev/null 2>&1; then
	echo -e "\n${GREEN}Installing gear-lever...${NC}"
	flatpak install -y --noninteractive flathub it.mijorus.gearlever &>/dev/null
fi

# install vs code
if ! command -v code &>/dev/null; then
	echo -e "\n${GREEN}Installing VS Code...${NC}"
	sudo apt -qq install -y wget gpg
	wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor --batch >packages.microsoft.gpg
	sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
	sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
	rm -f packages.microsoft.gpg
	sudo apt -qq install -y apt-transport-https
	sudo apt -qq update &>/dev/null
	sudo apt -qq install -y code
fi

# install remmina
if ! command -v remmina &>/dev/null; then
	echo -e "\n${GREEN}Installing Remmina...${NC}"
	sudo apt-add-repository -y ppa:remmina-ppa-team/remmina-next &>/dev/null
	sudo apt -qq update &>/dev/null
	sudo apt -qq install -y remmina remmina-plugin-rdp remmina-plugin-secret
fi

# install obs studio
if ! command -v obs &>/dev/null; then
	echo -e "\n${GREEN}Installing OBS Studio...${NC}"
	sudo add-apt-repository -y ppa:obsproject/obs-studio &>/dev/null
	sudo apt -qq update &>/dev/null
	sudo apt -qq install -y ffmpeg obs-studio
fi

# install vivaldi
if ! command -v vivaldi &>/dev/null; then
	echo -e "\n${GREEN}Installing Vivaldi...${NC}"
	curl --silent https://vivaldi.com/download/archive/?platform=linux --stderr - |
		grep -o -m 1 https://downloads.vivaldi.com/stable/vivaldi-stable_[0-9.-]*_amd64.deb |
		xargs wget -q -O ./vivaldi.deb
	sudo apt -qq install -y ./vivaldi.deb
	rm ./vivaldi.deb
fi

# install Chrome
if ! command -v google-chrome &>/dev/null; then
	echo -e "\n${GREEN}Installing Google Chrome...${NC}"
	wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O ./chrome.deb
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
		curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo gpg --dearmor --batch -o /etc/apt/trusted.gpg.d/anydesk.gpg
		echo "deb http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list >/dev/null
		sudo apt -qq update &>/dev/null
		sudo apt -qq install -y anydesk
	fi
fi

# install RustDesk
if ! command -v rustdesk &>/dev/null; then
	echo
	read -p "Do you want to install RustDesk (y/n)? " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		echo -e "\n${GREEN}Installing RustDesk...${NC}"
		repo="rustdesk/rustdesk"
		tag="$(latest_git_release "$repo")"
		echo "Latest tag: ${tag}"
		version="${tag:1}"
		wget -q "https://github.com/${repo}/releases/download/${tag}/rustdesk-${tag}-x86_64.deb" -O rustdesk.deb
		sudo apt -qq install -y ./rustdesk.deb
		rm ./rustdesk.deb
	fi
fi

# install proton vpn
if ! command -v protonvpn-app &>/dev/null; then
	echo -e "\n${GREEN}Installing Proton VPN...${NC}"
	if curl -fsSL --retry 3 --retry-delay 2 --retry-all-errors --user-agent "Mozilla/5.0" -o proton_repo.deb https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb; then
		sudo apt -qq install -y ./proton_repo.deb
		rm ./proton_repo.deb
		sudo apt -qq update &>/dev/null
		sudo apt -qq install -y proton-vpn-gnome-desktop
	fi
fi

# Install Dropbox
if ! command -v dropbox &>/dev/null; then
	echo -e "\n${GREEN}Installing Dropbox...${NC}"
	wget -q "https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2026.01.15_amd64.deb" -O dropbox.deb
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
	wget -q "https://github.com/${repo}/releases/download/${tag}/Koodo-Reader-${version}-amd64.deb" -O koodo.deb
	sudo apt -qq install -y ./koodo.deb
	rm ./koodo.deb
fi

# intall qBitTorrent
if ! command -v qbittorrent &>/dev/null; then
	echo -e "\n${GREEN}Installing qBitTorrent...${NC}"
	sudo add-apt-repository -y ppa:qbittorrent-team/qbittorrent-stable &>/dev/null
	sudo apt -qq update &>/dev/null
	sudo apt -qq install -y qbittorrent
fi

# install Spotify
if ! command -v spotify-client &>/dev/null; then
	echo
	echo -e "\n${GREEN}Installing Spotify...${NC}"
	curl -sS https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.asc | sudo gpg --dearmor --batch --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
	echo "deb https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list >/dev/null
	sudo apt -qq update &>/dev/null
	sudo apt -qq install -y spotify-client
fi

# install wine
if ! command -v wine &>/dev/null; then
	echo
	echo -e "\n${GREEN}Installing Wine...${NC}"
	sudo dpkg --add-architecture i386 &>/dev/null
	sudo mkdir -pm755 /etc/apt/keyrings
	sudo wget -q -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
	sudo wget -q -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources
	sudo apt -qq update &>/dev/null
	sudo apt -qq install -y --install-recommends winehq-stable
fi

# install MS Teams
if ! command -v teams-for-linux &>/dev/null; then
	echo
	echo -e "\n${GREEN}Installing MS Teams...${NC}"
	repo="IsmaelMartinez/teams-for-linux"
	tag="$(latest_git_release "$repo")"
	echo "Latest tag: ${tag}"
	version="${tag:1}"
	wget -q "https://github.com/${repo}/releases/download/${tag}/teams-for-linux_${version}_amd64.deb" -O teams.deb
	sudo apt -qq install -y ./teams.deb
	rm ./teams.deb
fi

# Install Drives Cosmic Applet
if ! flatpak info dev.cappsy.CosmicExtAppletDrives &>/dev/null; then
	echo -e "\n${GREEN}Installing Drives Cosmic Applet...${NC}"
	flatpak remote-add --if-not-exists --user cosmic https://apt.pop-os.org/cosmic/cosmic.flatpakrepo &>/dev/null
	flatpak install -y --noninteractive dev.cappsy.CosmicExtAppletDrives &>/dev/null
fi

# Install Clipboard Manager (Flatpak version broken due to Wayland data control sandboxing)
# TODO: Add back in when issues with the applet are fixed: https://github.com/cosmic-utils/clipboard-manager/issues/171
# if ! flatpak info io.github.cosmic_utils.cosmic-ext-applet-clipboard-manager &>/dev/null; then
# 	echo -e "\n${GREEN}Installing Clipboard Manager Cosmic Applet...${NC}"
# 	flatpak install -y --noninteractive io.github.cosmic_utils.cosmic-ext-applet-clipboard-manager &>/dev/null
# fi

# Install Minimon Cosmic Applet
if ! flatpak info io.github.cosmic_utils.minimon-applet &>/dev/null; then
	echo -e "\n${GREEN}Installing Minimon Cosmic Applet...${NC}"
	flatpak remote-add --if-not-exists --user cosmic https://apt.pop-os.org/cosmic/cosmic.flatpakrepo &>/dev/null
	flatpak install -y --noninteractive io.github.cosmic_utils.minimon-applet &>/dev/null
fi

# Setup PopOs specific config
sudo chmod u+x scripts/setup-pop-os-config.sh
scripts/setup-pop-os-config.sh

# Setup Fonts
sudo chmod u+x scripts/install-fonts.sh
scripts/install-fonts.sh

source ~/.bashrc
