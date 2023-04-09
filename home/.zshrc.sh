#!/usr/bin/env zsh

dotfiles="$HOME/dotfiles/dotfilesv2"

# Load main files.
# To benchmark startup: brew install coreutils, uncomment lines
# echo "Load start\t" $(gdate "+%s-%N")

source "$dotfiles/terminal/start.sh"
source "$dotfiles/terminal/completion.sh"
source "$dotfiles/terminal/highlight.sh"
source "$dotfiles/terminal/git-alias.sh"
source "$dotfiles/terminal/zsh-autosuggestion/zsh-autosuggestions.zsh"

# echo "Load end\t" $(gdate "+%s-%N")

autoload -U colors && colors

# Load and execute the prompt theming system.
fpath=("$dotfiles/terminal" $fpath)
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

alias -g zc="rm ~/.zcompdump*"

# Simple clear command.
alias c='clear'

function diff {
  git --no-pager diff --color=auto --no-ext-diff --no-index "$@"
}

freload() { while (( $# )); do; unfunction $1; autoload -U $1; shift; done }


export GPG_TTY=$(tty)