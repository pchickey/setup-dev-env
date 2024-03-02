#!/usr/bin/env bash
set -ex

SETUP_DEV_ENV_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export PATH=$HOME/.local/bin:$HOME/.cargo/bin:$PATH

sudo apt install -y \
    gitk \
    xclip \
    arandr \
    feh \
    scrot \
    imagemagick

if [ $(command -v dconf) ]; then
    dconf write /org/gnome/desktop/input-sources/xkb-options "['ctrl:nocaps']"
fi

if [ ! $(command -v alacritty) ]; then
    # For XPS 15 I ended up having to install from source
    sudo apt install -y \
        libfreetype6-dev \
        libexpat1-dev \
        libxcb1-dev \
        libxcb-render0-dev \
        libxcb-shape0-dev \
        libxcb-xfixes0-dev \
    	libfontconfig1-dev \
    	libxkbcommon-dev
    mkdir -p $HOME/src
    pushd $HOME/src
    git clone https://github.com/alacritty/alacritty
    cd alacritty
    cargo build --release
    ln -s $PWD/target/release/alacritty $HOME/.local/bin/alacritty
    popd
    ln -s $SETUP_DEV_ENV_DIR/dotfiles/alacritty $HOME/.config/alacritty
fi

if [ ! -d $HOME/.config/i3 ]; then
    sudo apt install -y i3
    ln -s $SETUP_DEV_ENV_DIR/dotfiles/i3 $HOME/.config/i3
    if [ ! -d $HOME/.screenlayout ]; then
        mkdir $HOME/.screenlayout
        touch $HOME/.screenlayout/home.sh
        chmod +x $HOME/.screenlayout/home.sh
    fi
fi

if [ ! -e $HOME/.local/bin/i3status_local ]; then
    ln -s $SETUP_DEV_ENV_DIR/dotfiles/bin/i3status_local $HOME/.local/bin/i3status_local
fi

if [ ! -f /etc/systemd/system/i3lock.service ]; then
    sudo ln -s $SETUP_DEV_ENV_DIR/i3lock.service /etc/systemd/system/i3lock.service
    ln -s $SETUP_DEV_ENV_DIR/i3lock.sh $HOME/.local/bin/i3lock.sh
    sudo systemctl enable i3lock.service
fi

if [ ! -d $HOME/.fonts ]; then
    mkdir -p $HOME/.fonts
    curl -sSfLO https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip
    unzip JetBrainsMono.zip
    for f in $SETUP_DEV_ENV_DIR/*.ttf
    do
        mv "$f" $HOME/.fonts/
    done
    rm JetBrainsMono.zip
    sudo fc-cache -f -v
fi

if [ ! $(command -v google-chrome) ]; then
    curl -fsSLO https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    # no idea why, but _apt user needs to be able to write for install to succeed
    chmod o+rw google-chrome-stable_current_amd64.deb
    sudo apt install -y ./google-chrome-stable_current_amd64.deb
fi
