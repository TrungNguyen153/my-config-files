#!/bin/sh

apt-get update
apt-get install -y fontconfig

mkdir -p $XDG_DATA_HOME/fonts \
  && cd $XDG_DATA_HOME/fonts \
  && curl --silent -fLo "Roboto Mono Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/RobotoMono/Regular/complete/Roboto%20Mono%20Nerd%20Font%20Complete.ttf \
  && fc-cache -fv

# Install Node version mananger
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
# chsh -s (which fish)
# Install node Long Time Suport (v16 now)
nvm install lts
# Install yarn for add feature
npm install --global yarn
yarn add global typescript-language-server

# Install cargo (installer of Rust app)
apt-get install -y cargo
