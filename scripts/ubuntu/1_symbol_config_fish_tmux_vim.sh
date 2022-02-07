#!/bin/bash


echo 'Start symbol link configs file...'

sudo ln -s -f $(realpath ../../.config/nvim) $HOME/.config
sudo ln -s -f $(realpath ../../.config/fish) $HOME/.config
sudo ln -s -f $(realpath ../../.tmux.conf) $HOME/.tmux.conf
sudo ln -s -f $(realpath ../../.tmux.conf.osx) $HOME/.tmux.conf.osx
sudo ln -s -f $(realpath ../../.tmux.powerline.conf) $HOME/.tmux.powerline.conf


echo 'Done all!'
