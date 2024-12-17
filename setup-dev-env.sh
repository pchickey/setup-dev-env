#!/usr/bin/env bash
set -ex

SETUP_DEV_ENV_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ ! -d "$HOME/.local/bin" ]; then
    mkdir -p $HOME/.local/bin
fi
export PATH=$PATH:$HOME/.local/bin

if [[ $(uname) == "Linux" ]]; then
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
        tree \
        apt-transport-https \
        gnupg-agent \
        jq \
        libfuse2
fi

if [ ! -d "$HOME/.zsh" ]; then
    ln -s $SETUP_DEV_ENV_DIR/dotfiles/zsh $HOME/.zsh
    ln -s $HOME/.zsh/zshrc $HOME/.zshrc
fi


if [[ $(uname) == "Linux" ]]; then
    if [ ! -f $SETUP_DEV_ENV_DIR/nvim.appimage ]; then
        if [[ $(uname -p) == "aarch64" ]]; then
            # i hope this is legit??
            curl -sSfL https://github.com/matsuu/neovim-aarch64-appimage/releases/download/v0.9.4/nvim-v0.9.4-aarch64.appimage -o nvim.appimage
        else
            curl -sSfLO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
        fi
        chmod +x nvim.appimage
        ln -s $SETUP_DEV_ENV_DIR/nvim.appimage $HOME/.local/bin/vim
    fi
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

if [[ ! $(git config --global user.name) == "Pat Hickey" ]]; then
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

if [ ! $(command -v mold) ] ; then
    if [[ $(uname) == "Linux" ]]; then
        # contents of provided install-build-deps, invoked here manually so im not
        # running sudo on their shell script
        sudo apt install -y gcc g++ g++-10
        # remainder of instructions are out of mold's readme:
        git clone https://github.com/rui314/mold.git
        mkdir mold/build
        pushd mold/build
        git checkout v2.4.1
        cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=c++ ..
        cmake --build . -j $(nproc)
        sudo cmake --build . --target install
        popd
        MOLD=/usr/local/bin/mold
    else
        brew install mold
        MOLD=$(which mold)
    fi

    NATIVE=$(rustc -vV | sed -n 's|host: ||p')
    echo "[target.${NATIVE}]" >> $HOME/.cargo/config
    echo "linker = \"/usr/bin/clang\"" >> $HOME/.cargo/config
    echo "rustflags = [\"-C\", \"link-arg=--ld-path=$MOLD\"]" >> $HOME/.cargo/config

fi

if [ ! -d $HOME/.fzf ]; then
    pushd $HOME
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
    popd
fi

if [ ! $(command -v cmake) ]; then
    if [[ $(uname) == "Darwin" ]]; then
        brew install cmake
    fi
fi

if [ ! $(command -v ninja) ]; then
    if [[ $(uname) == "Darwin" ]]; then
        brew install ninja
    fi
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
    if [[ $(uname) == "Linux" ]]; then
        sudo apt install -y libssl-dev
    fi
    cargo install sccache
    echo "[build]" >> $HOME/.cargo/config
    echo "rustc-wrapper = \"$HOME/.cargo/bin/sccache\"" >> $HOME/.cargo/config
    echo "incremental = false" >> $HOME/.cargo/config
fi

if [ ! $(command -v rg) ] ; then
    cargo install ripgrep
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

if [[ $(uname) == "Linux" ]]; then
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
fi
