#!/bin/sh


echo 'Start symbol link configs file...'
# echo $PWD

rm -r -f $HOME/.config/fish
ln -s -f $(realpath ../../.config/nvim) $HOME/.config
ln -s -f $(realpath ../../.config/fish) $HOME/.config
ln -s -f $(realpath ../../.tmux.conf) $HOME/.tmux.conf
ln -s -f $(realpath ../../.tmux.conf.osx) $HOME/.tmux.conf.osx
ln -s -f $(realpath ../../.tmux.powerline.conf) $HOME/.tmux.powerline.conf

echo 'Load Tmux tpm...'

tmux start-server && \
    tmux new-session -d && \
    sleep 1 && \
    $HOME/.tmux/plugins/tpm/scripts/install_plugins.sh && \
    tmux kill-server

echo 'Remove nvim/plugin complied...'
rm -rf $HOME/.config/nvim/plugin

echo 'Load Nvim Plugin...'
nvim --headless -c 'autocmd User PackerComplete quitall' #-c 'PackerSync' #dont need because bootstrap
# auto update nvim-treesitter after compile
nvim --headless -c 'TSInstallSync all' -c 'quitall'

echo 'Done all!'

