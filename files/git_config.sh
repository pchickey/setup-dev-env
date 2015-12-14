#! /usr/bin/env bash
set -e
git config --global user.name "Pat Hickey"
git config --global user.email "pat@moreproductive.org"
git config --global push.default simple
git config --global core.editor $(which vim)
git config --global core.excludesfile $HOME/.gitignore_global
git config --global color.ui true
git config --global log.decorate full
git config --global url.ssh://git@github.com:.insteadOf https://github.com
git config --global alias.unstage 'reset HEAD --'
git config --global alias.co 'commit -v'
git config --global alias.l 'log --stat'
git config --global alias.last 'log -1 HEAD'
