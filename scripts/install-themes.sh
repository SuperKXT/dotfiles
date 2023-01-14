#!/usr/bin/env bash

# install orchis theme
git clone https://github.com/vinceliuice/Orchis-theme orchis &&
	cd orchis &&
	./install.sh -t red -c light -s compact -l --round 0px --tweaks compact primary &&
	cd .. &&
	rm -rf orchis

# install tela icon theme
git clone https://github.com/vinceliuice/Tela-icon-theme tela &&
	cd tela &&
	source ./install.sh red &&
	cd .. &&
	rm -rf tela

# TODO Gedit theme

# TODO Tilix theme
