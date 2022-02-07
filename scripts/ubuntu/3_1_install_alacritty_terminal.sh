#!/bin/bash


cargo install alacritty

sudo ln -s -f $(realpath ../../.alacritty.yml) $HOME/.alacritty.yml.
