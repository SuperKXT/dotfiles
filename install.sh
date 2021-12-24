#!/usr/bin/env bash
############################
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

# dotfiles directory
dir=~/dotfiles

# old dotfiles backup directory
olddir=~/dotfiles_old

# list of files/folders to symlink in homedir
files=".bashrc .gitconfig .gitmessage .gitignore"

# create dotfiles_old in homedir
echo "Creating $olddir for backup of any existing dotfiles in ~"
mkdir -p $olddir
echo "...done"

# change to the dotfiles directory
echo "Changing to the $dir"
cd $dir || return
echo "...done"

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks
for file in $files; do
	echo "Moving any existing dotfiles from ~ to $olddir"
	mv "$HOME/$file" "$olddir/"
	echo "Creating symlink to $file in home directory."
	ln -s "$dir/$file" "$HOME/$file"
done

# move vscode tasks.json file to ~/.config/Code/User
codeTaskDir=~/.config/Code/User
echo "Moving existing tasks.json from $codeTaskDir to $olddir/vscode"
mv $codeTaskDir/tasks.json $olddir/vscode
echo "Moving vscode tasks.json file to $codeTaskDir"
ln -s $dir/vscode/tasks.json $codeTaskDir/tasks.json

curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash
