#!/bin/sh


echo 'Start symbol link configs file...'
# echo $PWD

rm -r -f $HOME/.config/fish
ln -s -f $(realpath ../../.config/nvim) $HOME/.config
ln -s -f $(realpath ../../.config/fish) $HOME/.config
ln -s -f $(realpath ../../.tmux.conf) $HOME/.tmux.conf
ln -s -f $(realpath ../../.tmux.conf.osx) $HOME/.tmux.conf.osx
ln -s -f $(realpath ../../.tmux.powerline.conf) $HOME/.tmux.powerline.conf

echo 'Done symbol!'

