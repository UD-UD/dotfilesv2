#!/bin/sh

## Prompt user to change to zsh
[ "${SHELL##/*/}" != "zsh" ] && echo 'Change default shell to zsh using: `chsh -s /bin/zsh`'

## Below lines of code pull the dotfile repo and install various configurations in your computer
dir="$HOME/dotfiles"
mkdir -p $dir # Create the subdirectories if not present

mkdir -p $dir/dotfiles_bkp

cp -f ~/.vim ~/.vimrc ~/.zshrc ~/.tmux ~/.tmux.conf ~./config/nvim  $dir/dotfiles_bkp

# remove existing dotfiles
# rm -rf ~/.zsh ~/.vim ~/.vimrc ~/.zshrc ~/.tmux ~/.tmux.conf ~/.config/nvim 2> /dev/null
rm -f ~/.zcompdump*
cd $dir

git clone --recursive https://github.com/UD-UD/dotfilesv2.git

cd dotfilesv2

sh install/install.sh

sh etc/symlink_dotfiles.sh

echo "==================== NEXT STEPS ====================="

echo 'Enforce GPG signed commits by `git config --global commit.gpgsign true`'

echo 'Add your GPG key to git config by `git config --global user.signingkey XXXXXXXXXX`'

