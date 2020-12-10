#!/usr/bin/env bash
set -ex

if [ ! -d "$HOME/.local/bin" ]; then
    mkdir -p $HOME/.local/bin
    export PATH=$PATH:$HOME/.local/bin
fi

if [ ! $(command -v make) ]; then
    sudo apt install \
        build-essential \
        vim \
        git \
        tmux \
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
        scrot
fi

if [ ! -d "$HOME/.zsh" ]; then
    ln -s $PWD/dotfiles/zsh $HOME/.zsh
    ln -s $HOME/.zsh/zshrc $HOME/.zshrc
fi



if [ ! -f "$HOME/.tmux.conf" ]; then
    if [ "tmux 2.5" == $(tmux -V) ] || [ "tmux master" == $(tmux -V)] ; then
        echo "Correct version of tmux installed, linking conf file"
    else
        echo "Incompatible version of tmux installed: " $(tmux -V)
        if [ ! -d "tmux" ]; then
            git clone https://github.com/tmux/tmux.git
        fi
        pushd tmux
        sh autogen.sh
        ./configure
        make
        sudo make install
        echo "Master version of tmux has been installed"
        popd
    fi
    ln -s $PWD/dotfiles/tmux.conf $HOME/.tmux.conf
fi

if [ ! -f $PWD/nvim.appimage ]; then
    curl -sSfLO https://github.com/neovim/neovim/releases/download/v0.4.4/nvim.appimage
    chmod +x nvim.appimage
    ln -s $PWD/nvim.appimage $HOME/.local/bin/nvim
fi


if [ ! -f "$HOME/.config/nvim/init.vim" ]; then
    mkdir -p $HOME/.config
    ln -s $PWD/dotfiles/nvim $HOME/.config/nvim
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
fi

if [ ! -f "$HOME/.cargo/bin/rg" ] ; then
    $HOME/.cargo/bin/cargo install ripgrep
fi

# LanguageClient-neovim depends on rust
if [ ! -d "$HOME/src/LanguageClient-neovim" ]; then
    mkdir -p $HOME/src
    pushd $HOME/src
    git clone https://github.com/autozimu/LanguageClient-neovim
    cd LanguageClient-neovim
    export PATH=$HOME/.cargo/bin:$PATH
    make release
    popd
fi

if [[ ! $(git config --global user.email) == "pat@moreproductive.org" ]]; then
    git config --global user.name "Pat Hickey"
    git config --global user.email "pat@moreproductive.org"
    git config --global push.default simple
    git config --global core.editor $(which vim)
    git config --global core.excludesfile $HOME/.dotfiles/gitignore_global
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
    sudo apt install \
        libfreetype6-dev \
        libexpat1-dev \
        libxcb1-dev \
        libxcb-render0-dev \
        libxcb-shape0-dev \
        libxcb-xfixes0-dev \
    libfontconfig1-dev
    mkdir -p $HOME/src
    pushd $HOME/src
    git clone https://github.com/alacritty/alacritty
    cd alacritty
    cargo build --release
    ln -s $PWD/target/release/alacritty $HOME/.local/bin/alacritty
    popd
    ln -s $PWD/dotfiles/alacritty $HOME/.config/alacritty
fi

if [ ! -d $HOME/.config/i3 ]; then
    sudo apt install i3
    ln -s $PWD/dotfiles/i3 $HOME/.config/i3
    if [ ! -d $HOME/.screenlayout ]; then
        mkdir $HOME/.screenlayout
        touch $HOME/.screenlayout/home.sh
        chmod +x $HOME/.screenlayout/home.sh
    fi
fi


if [ ! -f /etc/systemd/system/i3lock.service ]; then
    sudo ln -s $PWD/i3lock.service /etc/systemd/system/i3lock.service
    ln -s $PWD/i3lock.sh $HOME/.local/bin/i3lock.sh
    sudo systemctl enable i3lock.service
fi

if [ ! -d $HOME/.fonts ]; then
    mkdir -p $HOME/.fonts
    curl -sSfLO https://download.jetbrains.com/fonts/JetBrainsMono-1.0.2.zip
    unzip JetBrainsMono-1.0.2.zip
    for f in $PWD/JetBrainsMono-1.0.2/ttf/*.ttf
    do
        mv $f $HOME/.fonts/$(basename "$f")
    done
    rm -rf $PWD/JetBrainsMono-1.0.2
    rm JetBrainsMono-1.0.2.zip
    sudo fc-cache -f -v
fi

if [ ! -d $HOME/src/binaryen ]; then
    mkdir -p $HOME/src
    pushd $HOME/src
    git clone https://github.com/WebAssembly/binaryen
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


if [ ! $(command -v rust-analyzer) ]; then
    curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-linux \
        -o $HOME/.local/bin/rust-analyzer
    chmod +x $HOME/.local/bin/rust-analyzer
fi


if [ ! $(command -v sccache) ]; then
    sudo apt install libssl-dev
    cargo install sccache
    echo "[build]" >> $HOME/.cargo/config
    echo "rustc-wrapper = \"$HOME/.cargo/bin/sccache\"" >> $HOME/.cargo/config
    echo "incremental = false" >> $HOME/.cargo/config
fi
