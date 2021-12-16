
#!/usr/bin/env bash
set -ex

SETUP_DEV_ENV_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ ! -d "$HOME/.local/bin" ]; then
    mkdir -p $HOME/.local/bin
fi
export PATH=$PATH:$HOME/.local/bin

if [ ! -d "$HOME/.zsh" ]; then
    ln -s $SETUP_DEV_ENV_DIR/dotfiles/zsh $HOME/.zsh
    ln -s $HOME/.zsh/zshrc $HOME/.zshrc
fi

if [ ! -f "$HOME/.config/nvim/init.lua" ]; then
    mkdir -p $HOME/.config
    ln -s $SETUP_DEV_ENV_DIR/dotfiles/nvim $HOME/.config/nvim
fi

if [ ! -d "$HOME/.local/share/nvim/site/pack/paqs/opt/paq-nvim" ]; then
    git clone https://github.com/savq/paq-nvim.git \
        $HOME/.local/share/nvim/site/pack/paqs/opt/paq-nvim
fi

if [ ! -f "$HOME/.cargo/bin/rustc" ] ; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    export PATH=$HOME/.cargo/bin:$PATH
    rustup component add rustfmt
    rustup component add rust-src
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

if [ ! $(command -v rust-analyzer) ]; then
    curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-aarch64-apple-darwin.gz | gunzip -c - > ~/.local/bin/rust-analyzer
        -o $HOME/.local/bin/rust-analyzer
    chmod +x $HOME/.local/bin/rust-analyzer
fi

if [ ! $(command -v brew) ]; then
    $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)
fi

if [ ! $(command -v sccache) ]; then
    brew install sccache
fi

