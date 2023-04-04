#!/bin/sh

## Prompt user to change to zsh
[ "${SHELL##/*/}" != "zsh" ] && echo 'Change default shell to zsh using: `chsh -s /bin/zsh`'

## Below lines of code pull the dotfile repo and install various configurations in your computer
dir="$HOME/personal"
mkdir -p $dir # Create teh subdirectories if not present

git clone --recursive https://github.com/UD-UD/dotfilesv2.git

cd dotfilesv2

sh etc/symlink_dotfiles.sh
