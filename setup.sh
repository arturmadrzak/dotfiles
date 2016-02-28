#!/usr/bin/env bash


# setup .vimrc
if [ -f ~/.vimrc ]; then
  mv ~/.vimrc ~/.vimrc.bkp
fi
rm -f ~/.vimrc
ln -s `pwd`/vimrc ~/.vimrc

# setup .vim
if [ -d ~/.vim ]; then
  mv ~/.vim ~/.vim.bkp
fi
rm -f ~/.vim
ln -s `pwd`/vim ~/.vim

