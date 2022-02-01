#!/bin/bash



sudo ln -s -f $(realpath ../../.config/nvim) ~/.config
sudo ln -s -f $(realpath ../../.config/fish) ~/.config
sudo ln -s -f $(realpath ../../.tmux.conf) ~/.tmux.conf
sudo ln -s -f $(realpath ../../.tmux.conf.osx) ~/.tmux.conf.osx
sudo ln -s -f $(realpath ../../.tmux.powerline.conf) ~/.tmux.powerline.conf


echo 'Done all!'