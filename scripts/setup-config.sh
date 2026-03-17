#!/usr/bin/env bash

#################
#  Theme Setup  #
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

echo -e "\n${GREEN}Setting Tilix Config...${NC}"
dconf load /com/gexperts/Tilix/ <"$config_folder"/tilix.dconf

echo -e "\n${GREEN}Setting Up UFW firewall...${NC}"
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 3000:3050/tcp
sudo ufw allow 4000:4020/tcp
sudo ufw allow 5000:5020/tcp
sudo ufw allow 8000:8010/tcp
# Expo Go
sudo ufw allow 8081/tcp

# Update max number of allowed file watchers
echo -e "\n${GREEN}Configuring SysCTL...${NC}"
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

[ ! -f "$HOME/.ssh/config" ] &&
	echo -e "\n${GREEN}Setting Up SSH config...${NC}" &&
	ssh-keygen -t ed25519 -C "superkxt@outlook.com" -f ~/.ssh/id_github -N "" &&
	eval "$(ssh-agent -s)" &&
	ssh-add ~/.ssh/id_github &&
	cp ~/dotfiles/config/.ssh/* ~/.ssh/ &&
	echo -e "\n${GREEN}Authenticating gh cli with ssh key...${NC}" &&
	gh auth login -p ssh -s admin:ssh_signing_key -w &&
	echo -e "\n${GREEN}Adding SSH signing key...${NC}" &&
	gh ssh-key add ~/.ssh/id_github.pub --type signing
