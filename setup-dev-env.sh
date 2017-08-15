#!/usr/bin/env bash
set -e

if [ "Darwin" == $(uname -s) ]; then
	if [ ! -d /usr/local/Homebrew ]; then
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	fi
	brew install vim git tmux zsh curl reattach-to-user-namespace cmake libtool
elif [ $(which apt) ]; then
	sudo apt install build-essential vim git tmux zsh clang curl cmake
else
	echo "WARNING: Cannot automatically install your packages"
fi


if [ ! -d "$HOME/.dotfiles" ]; then
	echo "Cloning private dotfiles directory. This now requires github keying to be setup"
	git clone ssh://git@github.com/pchickey/dotfiles ~/.dotfiles
fi

if [ ! -d "$HOME/.zsh" ]; then
	git clone ssh://git@github.com/pchickey/zsh-config ~/.zsh
fi
if [ ! -f "$HOME/.zshrc" ]; then
	ln -s ~/.zsh/zshrc ~/.zshrc
fi
if [ ! "$SHELL" == $(which zsh) ]; then
	if [ "Darwin" == $(uname -s) ]; then
		echo "Adding brew installed zsh to list of acceptable shells"
		sudo sh -c "echo '$(which zsh)' >> /etc/shells"
	fi
	echo "Changing login shell to zsh"
	chsh -s $(which zsh)
fi


if [ ! -f "$HOME/.tmux.conf" ]; then
	ln -s ~/.dotfiles/tmux.conf ~/.tmux.conf
fi

if [ ! -f "$HOME/.ssh/rc" ]; then
	echo "if test \"\$SSH_AUTH_SOCK\" ; then" >> $HOME/.ssh/rc
	echo "  ln -sf \$SSH_AUTH_SOCK $HOME/.ssh/ssh_auth_sock" >> $HOME/.ssh/rc
	echo "fi" >> $HOME/.ssh/rc
fi

if [ ! -f "$HOME/.cargo/bin/rustc" ] ; then
	curl https://sh.rustup.rs -sSf | sh
fi

if [ ! -f "$HOME/.cargo/bin/rg" ] ; then
	$HOME/.cargo/bin/cargo install ripgrep
fi

if [ ! -f  "$HOME/.cargo/bin/rustfmt" ] ; then
	$HOME/.cargo/bin/cargo install rustfmt
fi

# Vim plugins depend on Rust stuff
if [ ! -d "$HOME/.vim" ]; then
	git clone git@github.com:pchickey/vim-config ~/.vim
	cd ~/.vim && ./boot.sh
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
	git config --global diff.submodule log
	git config --global status.submodulesummary 1
fi
