#!/usr/bin/env bash
set -e

if [ "Darwin" == $(uname -s) ]; then
	if [ ! -d /usr/local/Homebrew ]; then
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	fi
	brew install vim git tmux zsh curl
elif [ $(which apt) ]; then
	sudo apt install vim git tmux zsh clang curl
else
	echo "WARNING: Cannot automatically install your packages"
fi


if [ ! -d "$HOME/.dotfiles" ]; then
	echo "Cloning private dotfiles directory. This now requires github keying to be setup"
	git clone ssh://git@github.com:pchickey/dotfiles ~/.dotfiles
fi

if [ ! -d "$HOME/.zsh" ]; then
	git clone https://github.com/pchickey/zsh-config ~/.zsh
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

if [ ! -d "$HOME/.vim" ]; then
	git clone https://github.com/pchickey/vim-config ~/.vim
	cd ~/.vim && ./boot.sh
fi

if [ ! -f "$HOME/.tmux.conf" ]; then
	ln -s ~/.dotfiles/tmux.conf ~/.tmux.conf
fi

if ! which rustc; then
	curl https://sh.rustup.rs -sSf | sh
fi

if ! which rg; then
	$HOME/.cargo/bin/cargo install ripgrep
fi

if [[ ! $(git config --global user.email) == "pat@moreproductive.org" ]]; then
	git config --global user.name "Pat Hickey"
	git config --global user.email "pat@moreproductive.org"
	git config --global push.default simple
	git config --global core.editor $(which vim)
	git config --global core.excludesfile $HOME/.dotfiles/.gitignore_global
	git config --global color.ui true
	git config --global log.decorate full
	git config --global url.ssh://git@github.com:.insteadOf https://github.com
	git config --global alias.unstage 'reset HEAD --'
	git config --global alias.co 'commit -v'
	git config --global alias.l 'log --stat'
	git config --global alias.last 'log -1 HEAD'
	git config --global diff.submodule log
	git config --global status.submodulesummary 1
fi