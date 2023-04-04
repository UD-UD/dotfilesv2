#!/usr/bin/env zsh

dotfiles="$HOME/personal/dotfilesv2"

# Load main files.
# To benchmark startup: brew install coreutils, uncomment lines
# echo "Load start\t" $(gdate "+%s-%N")

source "$curr/terminal/start.sh"
source "$curr/terminal/completion.sh"
source "$curr/terminal/highlight.sh"

# echo "Load end\t" $(gdate "+%s-%N")

autoload -U colors && colors

# Load and execute the prompt theming system.
fpath=("$curr/terminal" $fpath)
autoload -Uz promptinit && promptinit
prompt 'ujjal'

# The icrnl setting tells the terminal driver in the kernel 
# to convert the CR character to LF on input. This way, applications only need to worry about one newline character;
# the same newline character that ends lines in files also ends lines of user input on the terminal, so the application doesn't need to have a special case for that.
# Fixes <Return> key bugs with some secure keyboards etc
stty icrnl


alias -g CNT="| wc -l"
alias -g COUNT="| wc -l"
alias -g SUM="| wc -l"
alias -g H="| head"
alias -g T="| tail"

# Simple clear command.
alias c='clear'
# Git short-cuts.
alias g='git'
alias ga='git add'
alias gr='git rm'
alias gf='git fetch'
alias gl='git pull'
alias gs='git status --short'
alias gd='git diff'
alias gdisc='git discard'

alias gp='git push'

function diff {
  git --no-pager diff --color=auto --no-ext-diff --no-index "$@"
}
