#!/usr/bin/env bash

#################
#  Theme Setup  #
#################

GREEN='\e[32m'
NC='\e[0m'

config_folder=~/dotfiles/config

echo -e "\n${GREEN}Installing Gnome Shell Extensions...${NC}"
rm -f ./install-gnome-extensions.sh
wget -N -q "https://raw.githubusercontent.com/ToasterUwU/install-gnome-extensions/master/install-gnome-extensions.sh" -O ./install-gnome-extensions.sh
chmod +x install-gnome-extensions.sh
./install-gnome-extensions.sh --enable --file ~/dotfiles/lists/shell-extensions.txt
rm ./install-gnome-extensions.sh
killall -3 gnome-shell
# Multi monitor addon not compatiable
# https://extensions.gnome.org/extension/921/multi-monitors-add-on/
git clone https://github.com/realh/multi-monitors-add-on.git
(
	cd multi-monitors-add-on || exit
	cp -r multi-monitors-add-on@spin83 ~/.local/share/gnome-shell/extensions/
)
rm -rf multi-monitors-add-on

echo -e "\n${GREEN}Setting Up Orchis Theme...${NC}"
git clone https://github.com/vinceliuice/Orchis-theme ~/orchis
(
	cd ~/orchis || exit
	./install.sh -t purple -c light -s compact -l --round 0px --tweaks compact primary
	cp -rvf ./src/firefox/chrome ~/.mozilla/firefox/*.default/
	cp -vf ./src/firefox/configuration/user.js ~/.mozilla/firefox/*.default/
)
rm -rf ~/orchis

echo -e "\n${GREEN}Setting Up Tela Icon Theme...${NC}"
git clone https://github.com/vinceliuice/Tela-icon-theme ~/tela
(
	cd ~/tela || exit
	./install.sh purple
)
rm -rf ~/tela

echo -e "\n${GREEN}Setting Up Gtk Terminal Styles...${NC}"
rm -f "$HOME/.config/gtk-3.0/gtk.css"
ln -s "$HOME/dotfiles/config/gtk.css" "$HOME/.config/gtk-3.0/gtk.css"

echo -e "\n${GREEN}Setting Up Config With Dconf...${NC}"
# Update settings with:
# dconf dump {{name}} >$config_folder/{{file}}.dconf

dconf load /org/gnome/desktop/ <"$config_folder"/desktop.dconf
dconf load /org/gnome/eog/ <"$config_folder"/eog.dconf
dconf load /org/gnome/shell/extensions/ <"$config_folder"/extensions.dconf
dconf load /org/gnome/gedit/ <"$config_folder"/gedit.dconf
sudo dconf load /org/gnome/gedit/ <"$config_folder"/gedit.sudo.dconf
dconf load /org/gnome/nautilus/ <"$config_folder"/nautilus.dconf
dconf load /org/gnome/system/ <"$config_folder"/system.dconf
dconf load /com/gexperts/Tilix/ <"$config_folder"/tilix.dconf
dconf load /org/gnome/weather/ <"$config_folder"/weather.dconf

# TODO setup gnome shell extensions status bar placement

echo -e "\n${GREEN}Setting Up UFW firewall...${NC}"
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 3000:3050/tcp
sudo ufw allow 3000:3050/udp
sudo ufw allow 5000:5050/tcp
sudo ufw allow 5000:5050/udp
sudo ufw allow 8000:8999/tcp
sudo ufw allow 8000:8999/udp
sudo ufw allow 8081/tcp

echo -e "\n${GREEN}Setting Up Wallpaper...${NC}"
cp -rTvf ~/dotfiles/wallpapers ~/Pictures/Wallpapers
gsettings set org.gnome.desktop.background picture-uri file:///home/"$(whoami)"/Pictures/Wallpapers/wavey-rainbow.jpg

echo -e "\n${GREEN}Setting Tilix as the default...${NC}"
sudo update-alternatives --set x-terminal-emulator /usr/bin/tilix.wrapper
sudo apt -qq install -y python3-pip python3-nautilus
pip install --user nautilus-open-any-terminal
nautilus -q
glib-compile-schemas ~/.local/share/glib-2.0/schemas/
gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal tilix

[ ! -f "$HOME/.ssh/config" ] &&
	echo -e "\n${GREEN}Setting Up SSH config...${NC}" &&
	ssh-keygen -t ed25519 -C "superkxt@outlook.com" -f ~/.ssh/id_ed25519 -N "" &&
	eval "$(ssh-agent -s)" &&
	ssh-add ~/.ssh/id_ed25519 &&
	cp ~/dotfiles/config/.ssh/* ~/.ssh/ &&
	echo -e "\n${GREEN}Authenticating gh cli with ssh key...${NC}" &&
	gh auth login -p ssh -s admin:ssh_signing_key -w &&
	echo -e "\n${GREEN}Adding SSH signing key...${NC}" &&
	gh ssh-key add ~/.ssh/id_ed25519.pub --type signing &&
	killall -3 gnome-shell
