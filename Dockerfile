FROM ubuntu:latest 

ENV DEBIAN_FRONTEND noninteractive

ENV HOME /root
ENV XDG_CONFIG_HOME /usr/local/etc
ENV XDG_DATA_HOME /usr/local/share
ENV XDG_CACHE_HOME /usr/local/cache

# Locales
ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8
RUN apt-get update && apt-get install -y locales && locale-gen en_US.UTF-8

#!/bin/bash
# Install Core Packages
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y git cmake build-essential silversearcher-ag exuberant-ctags
RUN apt-get install -y software-properties-common

# Add repo for install newest version
RUN add-apt-repository ppa:fish-shell/release-3 -y
RUN add-apt-repository ppa:neovim-ppa/stable -y
RUN apt-get update


RUN apt-get install -y fish neovim tmux fzf ripgrep
RUN apt-get install -y golang
RUN apt-get install -y python3-dev python3-pip python3-tk
RUN apt-get install -y ranger curl fontconfig 

# # Install Zoxide searching for fish (optional)
# RUN curl -sS https://webinstall.dev/zoxide | bash
# Enable Fish by Default
RUN grep -q -F 'fish' ~/.bashrc || echo 'exec fish' >> ~/.bashrc

RUN update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
RUN update-alternatives --config vi
RUN update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
RUN update-alternatives --config vim
RUN update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
RUN update-alternatives --config editor

# Install fonts
RUN mkdir -p $XDG_DATA_HOME/fonts \
  && cd /usr/local/share/fonts \
  && curl --silent -fLo "Roboto Mono Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/RobotoMono/Regular/complete/Roboto%20Mono%20Nerd%20Font%20Complete.ttf \
  && fc-cache -fv

# Install nvm ( Node Version Manager )
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash

# Install dotfiles
RUN echo "Installing dotfiles..."

RUN mkdir -p $XDG_CONFIG_HOME/nvim
RUN mkdir -p $XDG_CONFIG_HOME/fish

COPY ./.config/fish $XDG_CONFIG_HOME/fish
COPY ./.config/nvim $XDG_CONFIG_HOME/nvim
# RUN git clone --depth 1 https://github.com/wbthomason/packer.nvim\
#  $XDG_DATA_HOME/nvim/site/pack/packer/start/packer.nvim

# RUN rm -rf $XDG_DATA_HOME/nvim/plugin

# auto Compile Packer
RUN nvim --headless -c 'autocmd User PackerComplete quitall' #-c 'PackerSync' #dont need because bootstrap
# auto update nvim-treesitter after compile
RUN nvim --headless -c 'TSInstallSync all' -c 'quitall'

# tmux config
COPY .tmux.conf $HOME/.tmux.conf
COPY .tmux.conf.osx $HOME/.tmux.conf.osx
COPY .tmux.powerline.conf $HOME/.tmux.powerline.conf
RUN git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm \
  && $HOME/.tmux/plugins/tpm/bin/install_plugins

# auto forward to fish
ENTRYPOINT [ "bash" ]
