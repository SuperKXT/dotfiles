#!/usr/bin/env bash

#################
#  Theme Setup  #
#################

GREEN='\e[32m'
NC='\e[0m'

echo -e "\n${GREEN}Installing Gnome Shell Extensions...${NC}"
rm -f ./install-gnome-extensions.sh &&
	wget -N -q "https://raw.githubusercontent.com/cyfrost/install-gnome-extensions/master/install-gnome-extensions.sh" -O ./install-gnome-extensions.sh &&
	chmod +x install-gnome-extensions.sh &&
	./install-gnome-extensions.sh --enable --file ~/dotfiles/lists/shell-extensions.txt &&
	rm ./install-gnome-extensions.sh &&
	killall -3 gnome-shell

echo -e "\n${GREEN}Setting Up Orchis Theme...${NC}"
git clone https://github.com/vinceliuice/Orchis-theme orchis &&
	cd orchis &&
	./install.sh -t red -c light -s compact -l --round 0px --tweaks compact primary &&
	cp -rvf ./src/firefox/chrome ~/.mozilla/firefox/*.default/ &&
	cp -vf ./src/firefox/configuration/user.js ~/.mozilla/firefox/*.default/ &&
	cd .. &&
	rm -rf orchis

echo -e "\n${GREEN}Setting Up Tela Icon Theme...${NC}"
git clone https://github.com/vinceliuice/Tela-icon-theme tela &&
	cd tela &&
	./install.sh red &&
	cd .. &&
	rm -rf tela

echo -e "\n${GREEN}Setting Up Gtk Terminal Styles...${NC}"
rm -f "$HOME/.config/gtk-3.0/gtk.css" &&
	ln -s "$HOME/dotfiles/theme/gtk.css" "$HOME/.config/gtk-3.0/gtk.css"

echo -e "\n${GREEN}Setting Up Config With Dconf...${NC}"
# Update settings with:
# dconf dump {{name}} >./theme/{{file}}.dconf

dconf load /org/gnome/desktop/ <./theme/desktop.dconf
dconf load /org/gnome/eog/ <./theme/eog.dconf
dconf load /org/gnome/shell/extensions/ <./theme/extensions.dconf
dconf load /org/gnome/gedit. <./theme/gedit.dconf
sudo dconf load /org/gnome/gedit/ <./theme/gedit.sudo.dconf
dconf load /org/gnome/nautilus/ <./theme/nautilus.dconf
dconf load /org/gnome/system/ <./theme/system.dconf
dconf load /com/gexperts/Tilix/ <./theme/tilix.dconf
dconf load /org/gnome/weather/ <./theme/weather.dconf

# TODO setup gnome shell extensions status bar placement

sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 3000-3050/tcp
sudo ufw allow 3000-3050/udp
sudo ufw allow 5000-5050/tcp
sudo ufw allow 5000-5050/udp
sudo ufw allow 8000-8999/tcp
sudo ufw allow 8000-8999/udp

# TODO Add ssh alias for github -> gh

killall -3 gnome-shell
