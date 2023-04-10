#!/usr/bin/env bash

if test ! "$( command -v brew )"; then
    echo "============================== Installing homebrew =============================="
    ruby -e "$( curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install )"
fi

echo -e "============================== Updating Homebrew =============================="

brew update
# Upgrade any already-installed formulae.
brew upgrade

echo -e "============================== Installing packages =============================="

formulas=(
    git-delta
    gnupg
    neovim
    python3
    node
    nvm
    git
    openjdk
    gh
)

for formula in "${formulas[@]}"; do
    formula_name=$( echo "$formula" | awk '{print $1}' )
    if brew list "$formula_name" > /dev/null 2>&1; then
        echo "$formula_name already installed... skipping."
    else
        brew install "$formula"
    fi
done

echo -e "============================== Installing Rust =============================="
if test ! "$( command -V rustup )"; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

echo -e "============================== Recompiling ZSH =============================="
zc





