#!/usr/bin/env bash

#################
#  Theme Setup  #
#################

# install orchis theme
echo
echo "Setting up orchis theme..."
git clone https://github.com/vinceliuice/Orchis-theme orchis &&
	cd orchis &&
	./install.sh -t red -c light -s compact -l --round 0px --tweaks compact primary &&
	cd .. &&
	rm -rf orchis

# install tela icon theme
echo
echo "Setting up tela icon theme..."
git clone https://github.com/vinceliuice/Tela-icon-theme tela &&
	cd tela &&
	source ./install.sh red &&
	cd .. &&
	rm -rf tela

# add gtk terminal style config
echo
echo "Setting up gtk terminal styles..."
rm "$HOME/.config/gtk-3.0/gtk.css" &&
	ln -s "$HOME/dotfiles/theme/gtk.css" "$HOME/.config/gtk-3.0/gtk.css"

# TODO Gedit theme

# TODO Tilix theme
