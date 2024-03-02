#!/usr/bin/env bash
set -ex

SETUP_DEV_ENV_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ ! -d "$HOME/.local/bin" ]; then
    mkdir -p $HOME/.local/bin
fi
export PATH=$PATH:$HOME/.local/bin

sudo apt install -y \
    build-essential \
    vim \
    git \
    zsh \
    clang \
    curl \
    cmake \
    bison \
    flex \
    ninja-build \
    autoconf \
    pkg-config \
    libevent-dev \
    libncurses-dev \
    gitk \
    tree \
    xclip \
    arandr \
    feh \
    scrot \
    imagemagick \
    apt-transport-https \
    gnupg-agent \
    jq \
    libfuse2

if [ ! -d "$HOME/.zsh" ]; then
    ln -s $SETUP_DEV_ENV_DIR/dotfiles/zsh $HOME/.zsh
    ln -s $HOME/.zsh/zshrc $HOME/.zshrc
fi


if [ ! -f $SETUP_DEV_ENV_DIR/nvim.appimage ]; then
    curl -sSfLO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod +x nvim.appimage
    ln -s $SETUP_DEV_ENV_DIR/nvim.appimage $HOME/.local/bin/vim
fi

if [ ! -f "$HOME/.config/nvim/init.lua" ]; then
    mkdir -p $HOME/.config
    ln -s $SETUP_DEV_ENV_DIR/dotfiles/nvim $HOME/.config/nvim
fi

if [ ! -f "$HOME/.ssh/config" ]; then
    echo "AddKeysToAgent yes" >> $HOME/.ssh/config
fi

if [ ! -f "$HOME/.ssh/rc" ]; then
    echo "if test \"\$SSH_AUTH_SOCK\" ; then" >> $HOME/.ssh/rc
    echo "  ln -sf \$SSH_AUTH_SOCK $HOME/.ssh/ssh_auth_sock" >> $HOME/.ssh/rc
    echo "fi" >> $HOME/.ssh/rc
fi

if [ ! -f "$HOME/.cargo/bin/rustc" ] ; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    export PATH=$HOME/.cargo/bin:$PATH
    rustup component add rustfmt
    rustup component add rust-src
    rustup component add rust-analyzer
    rustup target add wasm32-unknown-unknown
    rustup target add wasm32-wasi
fi
export PATH=$HOME/.cargo/bin:$PATH

if [ ! -f "$HOME/.cargo/bin/rg" ] ; then
    $HOME/.cargo/bin/cargo install ripgrep
fi

if [[ ! $(git config --global user.email) == "pat@moreproductive.org" ]]; then
    git config --global user.name "Pat Hickey"
    git config --global user.email "pat@moreproductive.org"
    git config --global push.default simple
    git config --global core.editor $(which vim)
    if [ ! -f "$HOME/.gitignore" ]; then
        ln -s $SETUP_DEV_ENV_DIR/dotfiles/gitignore_global $HOME/.gitignore
    fi
    git config --global core.excludesfile $HOME/.gitignore
    git config --global color.ui true
    git config --global log.decorate full
    git config --global alias.unstage 'reset HEAD --'
    git config --global alias.co 'commit -v'
    git config --global alias.l 'log --stat'
    git config --global alias.last 'log -1 HEAD'
    git config --global alias.sms 'submodule status --recursive'
    git config --global alias.smu 'submodule update --init --recursive'
    git config --global merge.conflictstyle 'diff3'
    git config --global diff.submodule log
    git config --global status.submodulesummary 1
fi
if [ ! -d $HOME/.config/git/template ]; then
    mkdir -p $HOME/.config/git/template
    echo "ref: refs/heads/main" > $HOME/.config/git/template/HEAD
    git config --global init.templateDir $HOME/.config/git/template
fi

if [ ! -d $HOME/.fzf ]; then
    pushd $HOME
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
    popd
fi

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

if [ ! -d $HOME/src/binaryen ]; then
    mkdir -p $HOME/src
    pushd $HOME/src
    git clone --recursive https://github.com/WebAssembly/binaryen
    cd binaryen
    mkdir build
    cd build
    cmake -G Ninja ..
    ninja
    for f in $HOME/src/binaryen/build/bin/*
    do
        ln -s $f $HOME/.local/bin/$(basename "$f")
    done
    popd
fi

if [ ! -d $HOME/src/wabt ]; then
    mkdir -p $HOME/src
    pushd $HOME/src
    git clone --recursive https://github.com/WebAssembly/wabt
    cd wabt
    mkdir build
    cd build
    cmake -G Ninja ..
    ninja
    for f in wasm2wat wat2wasm wasm-objdump
    do
        ln -s $PWD/$f $HOME/.local/bin/$f
    done
    popd
fi


if [ ! $(command -v sccache) ]; then
    sudo apt install -y libssl-dev
    cargo install sccache
    echo "[build]" >> $HOME/.cargo/config
    echo "rustc-wrapper = \"$HOME/.cargo/bin/sccache\"" >> $HOME/.cargo/config
    echo "incremental = false" >> $HOME/.cargo/config
fi

if [ ! $(command -v wasm-tools) ]; then
    cargo install wasm-tools
fi

if [ ! $(command -v wit-bindgen) ]; then
    cargo install wit-bindgen-cli
fi

if [ ! $(command -v wit-deps) ]; then
    cargo install wit-deps-cli
fi

if [ ! $(command -v docker) ]; then
     curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
     sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io
    sudo docker run hello-world
fi


if [ ! $(command -v google-chrome) ]; then
    curl -fsSLO https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    # no idea why, but _apt user needs to be able to write for install to succeed
    chmod o+rw google-chrome-stable_current_amd64.deb
    sudo apt install -y ./google-chrome-stable_current_amd64.deb
fi
