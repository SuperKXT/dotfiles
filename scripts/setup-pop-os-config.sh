#!/usr/bin/env bash

#################
#  Pop OS Specific Setup  #
#################

GREEN='\e[32m'
NC='\e[0m'

config_folder=~/dotfiles/config

echo -e "\n${GREEN}Allowing superkxt to use the serial port (restart required)...${NC}"
sudo usermod -a -G dialout "$USER"

echo -e "\n${GREEN}Setting Up Pop Launcher Plugins...${NC}"
mkdir -p ~/.local/share/pop-launcher/plugins/web
echo '( rules: [ ( matches: ["www"], queries: [(name: "Open Website", query: "http://")] ), ] )' >~/.local/share/pop-launcher/plugins/web/config.ron
ln -sfT ~/dotfiles/config/pop-launcher/code-plugin ~/.local/share/pop-launcher/plugins/code-plugin

echo -e "\n${GREEN}Setting Up Tela Icon Theme...${NC}"
git clone https://github.com/vinceliuice/Tela-icon-theme ~/tela
(
	cd ~/tela || exit
	./install.sh purple
)
rm -rf ~/tela

echo -e "\n${GREEN}Setting Up Cosmic Config...${NC}"
# ! Use the following commands to update the cosmic config in the repo
# cp -rT ~/.config/cosmic/ ~/dotfiles/config/cosmic/
# rm -rf ~/dotfiles/config/cosmic/com.system76.CosmicTheme.Light
# rm -rf ~/dotfiles/config/cosmic/com.system76.CosmicTheme.Dark
# rm -rf ~/dotfiles/config/cosmic/com.system76.CosmicPortal
# rm -rf ~/dotfiles/config/cosmic/com.system76.CosmicStore
# rm -rf ~/dotfiles/config/cosmic/com.system76.CosmicPlayer
# rm -rf ~/dotfiles/config/cosmic/com.system76.CosmicAppList
# rm -rf ~/dotfiles/config/cosmic/com.system76.CosmicSettingsDaemon
# rm -f  ~/dotfiles/config/cosmic/com.system76.CosmicSettings.Wallpaper/v1/recent-folders
cp -rT "$config_folder"/cosmic/ ~/.config/cosmic/
