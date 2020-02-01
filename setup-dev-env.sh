#!/usr/bin/env bash
set -ex

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
	dconf-tools \
	gitk \
	tree \
	xclip \
	arandr \
	feh

if [ ! -d "$HOME/.zsh" ]; then
	ln -s $PWD/zsh $HOME/.zsh
	ln -s $HOME/.zsh/zshrc $HOME/.zshrc
fi

if [ ! "$SHELL" == $(which zsh) ]; then
	echo "Changing login shell to zsh"
	chsh -s $(which zsh)
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
fi

if [ ! -f "$HOME/.cargo/bin/rg" ] ; then
	$HOME/.cargo/bin/cargo install ripgrep
fi

if [ ! -f  "$HOME/.cargo/bin/rustfmt" ] ; then
	$HOME/.cargo/bin/rustup component add rustfmt
fi

if [ ! -f  "$HOME/.cargo/bin/rls" ] ; then
	$HOME/.cargo/bin/rustup component add rls
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
	git config --global diff.submodule log
	git config --global status.submodulesummary 1
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
	sudo add-apt-repository ppa:mmstick76/alacritty
	sudo apt update
	sudo apt install alacritty
	ln -s $PWD/dotfiles/alacritty $HOME/.config/alacritty
fi

if [ ! -d $HOME/.config/i3 ]; then
	sudo apt install i3
	ln -s $PWD/dotfiles/i3 $HOME/.config/i3
fi


if [ ! -d $HOME/.fonts ]; then
	mkdir -p $HOME/.fonts
	for f in $PWD/JetBrainsMono-1.0.2/ttf/*.ttf
	do
		ln -s $f $HOME/.fonts/$(basename "$f")
	done
	sudo fc-cache -f -v
fi
