#!/usr/bin/fish

apt-get -y install libfontconfig libfontconfig1-dev
cargo install alacritty

ln -s -f $(realpath ../../.alacritty.yml) $HOME/.alacritty.yml.
