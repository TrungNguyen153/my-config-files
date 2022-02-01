#!/bin/bash

sudo rm -rf ~/.config/nvim
sudo rm -rf ~/.config/fish
sudo rm -rf ~/.tmux.conf
sudo rm -rf ~/.tmux.conf.osx
sudo rm -rf ~/.tmux.powerline.conf

sudo ln -s $(realpath ../../.config/nvim/) ~/.config/nvim
sudo ln -s $(realpath ../../.config/fish/) ~/.config/fish
sudo ln -s $(realpath ../../.tmux.conf) ~/.tmux.conf
sudo ln -s $(realpath ../../.tmux.conf.osx) ~/.tmux.conf.osx
sudo ln -s $(realpath ../../.tmux.powerline.conf) ~/.tmux.powerline.conf


echo 'Done all!'