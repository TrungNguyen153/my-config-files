#!/bin/bash



## Add repository
sudo add-apt-repository ppa:fish-shell/release-3 -y
sudo add-apt-repository ppa:neovim-ppa/stable -y

## Install Core Packages
sudo apt update
sudo apt upgrade -y
sudo apt install -y cmake build-essential silversearcher-ag exuberant-ctags
sudo apt install -y software-properties-common

## Install python
sudo apt install -y python3 python3-pip

## Install terminal explorer management
sudo apt install -y ranger

## install git
sudo apt install -y git

## Main super star
sudo apt install -y fish neovim tmux fzf ripgrep

## Enable nvim as default selection priority
sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
sudo update-alternatives --config vi
sudo update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
sudo update-alternatives --config vim
sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
sudo update-alternatives --config editor

# Enable Fish by Default
# Option 1, seem not work, unknow why
# sudo chsh -s /usr/bin/fish
# option 2, work by start fish at end bashrc
grep -q -F 'fish' ~/.bashrc || echo 'exec fish' >> ~/.bashrc

## Pre-create config dir
mkdir -p ~/.config/fish
mkdir -p ~/.config/nvim

## Install Tmux Plugin Manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# install neovim python support
pip3 install pynvim

# # Install Fish package manager
curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish

# # Install fzf fish support
# exec fish
## older one, unmaintained
# fisher add jethrokuan/fzf
## newer one, not working
# sudo apt install -y bat fd-find fzf
# fisher add patrickf3139/fzf.fish

# Another option is to use fzf extension
sudo apt remove -y fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install


echo "All Done."