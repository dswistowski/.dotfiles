#!/bin/bash

for stow_dir in nvim tmux zsh tools git skhd alacritty
do
    stow $stow_dir
done
