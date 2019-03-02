#!/bin/bash

set -e

if [ ! -d ~/dotfiles ]; then
  echo "Cloning dotfiles"
  # the reason we dont't copy the files individually is, to easily push changes
  # if needed
  cd ~/
  git clone --recursive https://github.com/vdenoise/dotfiles.git
fi

cd ~/dotfiles 
echo "git remote"
git remote set-url origin git@github.com:vdenoise/dotfiles.git

ln -s $(pwd)/vimrc ~/.vimrc
ln -s $(pwd)/zshrc ~/.zshrc
ln -s $(pwd)/tmuxconf ~/.tmux.conf
ln -s $(pwd)/tigrc ~/.tigrc
ln -s $(pwd)/git-prompt.sh ~/.git-prompt.sh
ln -s $(pwd)/gitconfig ~/.gitconfig
ln -s $(pwd)/agignore ~/.agignore
ln -s $(pwd)/sshconfig ~/.ssh/config


/usr/sbin/sshd -D
