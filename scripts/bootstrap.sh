#!/bin/sh
# This script creates symlinks from the home directory to any desired dotfiles in $dir

# dotfiles directory
dir=~/Code/dotfiles
# list of files/folders to create symlinks
symlink=(.zshrc .zprofile .path .aliases .exports .functions .extra .gitconfig .gitignore .macos .backupignore)

# change to the dotfiles directory
echo "Changing to the $dir directory"
cd $dir
echo "...done"

# remove any existing dotfiles & create symlinks
for file in $symlink; do
	echo "Remove $file ..."
	rm -r ~/$file
	echo "... and symlink $file to ~"
	ln -s $dir/$file ~/$file
done

# reload bash profile
source ~/.zshrc
