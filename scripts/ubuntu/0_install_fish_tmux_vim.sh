#!/bin/sh



## Install Core Packages
apt update
apt upgrade -y
apt install -y cmake build-essential silversearcher-ag exuberant-ctags
apt install -y software-properties-common

## Add repository (require software-properties-common)
add-apt-repository ppa:fish-shell/release-3 -y
add-apt-repository ppa:neovim-ppa/stable -y
add-apt-repository ppa:deadsnakes/ppa -y # Python repo

## Install python
apt install -y python3.9 python3-pip

## Install terminal explorer management
apt install -y ranger

## install git and curl
apt install -y git curl unzip

## Main super star
apt install -y fish neovim tmux fzf ripgrep

## Enable nvim as default selection priority
update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
update-alternatives --config vi
update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
update-alternatives --config vim
update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
update-alternatives --config editor

# Enable Fish by Default
# Option 1, seem not work, unknow why
# sudo chsh -s /usr/bin/fish
# option 2, work by start fish at end bashrc
grep -q -F 'fish' ~/.bashrc || echo 'exec fish' >> ~/.bashrc

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
apt remove -y fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install


echo "All Done."
