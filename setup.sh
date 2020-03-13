#!/usr/bin/env bash

function backup()
{
    target=$1
    if [ -f "$target" ]; then
        mv "$target" "$target".bkp
    fi
}

git submodule update --init

BASE_PATH=`pwd`

# setup .vimrc
backup ~/.vimrc
ln -s `pwd`/vimrc ~/.vimrc
ln -sf `pwd`/vimrc-ide ~/.vimrc-ide
ln -sf `pwd`/ctags ~/.ctags

# setup .vim
if [ -d ~/.vim ]; then
  mv ~/.vim ~/.vim.bkp
fi

rm -f ~/.vim
ln -s `pwd`/vim ~/.vim

# setup tmux
backup ~/.tmux.conf
ln -s `pwd`/tmux.conf ~/.tmux.conf

# setup bash_aliases
backup ~/.bash_aliases
ln -s `pwd`/bash_aliases ~/.bash_aliases

# install powerfonts
cd $(BASE_PATH)/powerline-fonts && ./install.sh

# install
cd $(BASE_PATH)/vim/bundle/youcompleteme && python3 install.py --clangd-completer --rust-completer
#
# install bash fuzzy completer
cd fzf && ./install
