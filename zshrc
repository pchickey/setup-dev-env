uname=`uname | tr A-Z a-z`

# site-wide settings
if [[ -f /etc/zshrc ]]; then
  . /etc/zshrc
fi

# history
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt inc_append_history

# local functions
fpath=($fpath ~/.zsh/functions)

# emacs key bindings
bindkey -e

bindkey "^f" forward-word
bindkey "^b" backward-word

# completion
autoload -U compinit colors promptinit spectrum
compinit
colors
spectrum
promptinit

export EDITOR=vim

# Aliases
alias ls='ls -G -F -h'
alias grep='grep --color=auto'
alias rm='rm -v'
alias vim='vim -p'

topit() { /usr/bin/top -p `pgrep $1` }
vimfind() { find -name $1 -exec vim -p {} + }

if [[ $TERM == "dumb" ]] ; then
  alias ls='ls --color=none'
else
  # colored tab-completion
  zstyle -e ':completion:*:default' list-colors 'reply=("${(@s.:.)LS_COLORS}")'
fi

if [[ $TERM == "xterm" ]] ; then
  export TERM="xterm-256color"
fi

if [[ $uname == "darwin" ]]; then
else
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
fi

# prompt
prompt trevor 014 blue red default yellow

# cabal completion
compdef -a _cabal cabal

# use the default dircolors, despite the awesome 256 color palette
#eval `dircolors -b /etc/DIR_COLORS`

if [[ -d /usr/local/bin ]]; then
  export PATH=/usr/local/bin:$PATH
fi

if [[ -d ~/.cargo/bin ]]; then
  export PATH=$HOME/.cargo/bin:$PATH
  export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"
  export CARGO_HOME=$HOME/.cargo
fi

if [[ -d ~/.local/bin ]]; then
  export PATH=$HOME/.local/bin:$PATH
fi

# add dotfiles bin to path, if exists
if [[ -d ~/.dotfiles/bin ]]; then
  export PATH=$HOME/.dotfiles/bin:$PATH
fi

# load in local config, if available
if [[ -f ~/.zsh/site-config ]]; then
  . ~/.zsh/site-config
fi

