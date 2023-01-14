#!/usr/bin/env bash
############################
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

# Create symlinks for the completions in the completions folder
echo "Creating symlink for dotfiles in home directory."
cp -rsTvf ~/dotfiles/config ~/

./scripts/install-completions
