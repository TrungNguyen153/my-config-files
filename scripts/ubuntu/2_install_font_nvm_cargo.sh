#!/usr/bin/fish

sudo apt-get update
sudo apt-get install -y fontconfig

mkdir -p $XDG_DATA_HOME/fonts \
  && cd $XDG_DATA_HOME/fonts \
  && curl --silent -fLo "Roboto Mono Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/RobotoMono/Regular/complete/Roboto%20Mono%20Nerd%20Font%20Complete.ttf \
  && fc-cache -fv

# Install Node version mananger
mkdir -p $XDG_CONFIG_HOME/nvm
export NVM_DIR=$XDG_CONFIG_HOME/nvm && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
# chsh -s (which fish)
# Install node Long Time Suport (v16 now)
nvm install lts
# Install yarn for add feature
npm install --global yarn
yarn add --global typescript-language-server

# Install cargo (installer of Rust app)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
