#!/usr/bin/bash

# Dependency alacritty
sudo apt-get install -y cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev
# cargo install alacritty

# Install from prebuild source
sudo add-apt-repository ppa:mmstick76/alacritty -y
sudo apt update
sudo apt install -y alacritty

ln -s -f $(realpath ../../.alacritty.yml) $HOME/.alacritty.yml

