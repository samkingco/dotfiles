#!/bin/sh
# This script creates symlinks from the home directory to any desired dotfiles in $dir

# dotfiles directory
dir=~/src/dotfiles
# list of files/folders to create symlinks
symlink=".bash_profile .bash_prompt .path .aliases .exports .functions .extra .gitconfig .gitignore .macos .backupignore"

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
source ~/.bash_profile
