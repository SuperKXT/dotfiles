#!/usr/bin/env bash

#################
#  Theme Setup  #
#################

GREEN='\e[32m'
NC='\e[0m'

echo -e "\n${GREEN}Setting Up Orchis Theme...${NC}"
git clone https://github.com/vinceliuice/Orchis-theme orchis &&
	cd orchis &&
	./install.sh -t red -c light -s compact -l --round 0px --tweaks compact primary &&
	cd .. &&
	rm -rf orchis

# TODO Install firefox orchis theme

echo -e "\n${GREEN}Setting Up Tela Icon Theme...${NC}"
git clone https://github.com/vinceliuice/Tela-icon-theme tela &&
	cd tela &&
	./install.sh red &&
	cd .. &&
	rm -rf tela

echo -e "\n${GREEN}Setting Up Gtk Terminal Styles...${NC}"
rm -f "$HOME/.config/gtk-3.0/gtk.css" &&
	ln -s "$HOME/dotfiles/theme/gtk.css" "$HOME/.config/gtk-3.0/gtk.css"

# TODO Gedit theme

# TODO Tilix theme

# TODO Set theme, icons, and fonts
