#! /usr/bin/env bash
wget https://github.com/tmux/tmux/releases/download/2.1/tmux-2.1.tar.gz
tar xf tmux-2.1.tar.gz
cd tmux-2.1
./configure
make
make install

