# Setup Dev Environment

An shell script to set up my own prefered development tools and dotfiles.

## Compatibility

Works on MacOS and Ubuntu 24.04

## Optional Configs

Set these in ~/.zsh/site-config for per-machine configuration

### Set a prompt color

Visual cue for what machine I'm logged into.

```sh
export PROMPT_PRIMARY='005'
```

### Disable ssh agent

On machines I only ever ssh to, I want to forward my ssh agent and not start
one on the remote machine.

```sh
export DISABLE_SSH_AGENT=1
```

### Disable


## Manual steps

### Zsh default shell

```sh
chsh -s $(which zsh)
```

### SSH private keys

The actual private keys are resident on the yubikey, but you still need a
private key file, not in this repo out of exceeding paranoia. chmod them 600.

### SSH and GPG forwarding

Disable start_agent in the .zshrc on machines that are accessed via ssh, so
that keys are forwarded to remote machine.

GPG agent can be forwarded as well: https://wiki.gnupg.org/AgentForwarding

### Import GPG keys

```sh
gpg --import yubikey-5c-1-public.pgp
gpg --list-public-keys
gpg --edit-key (fingerprint) trust 5
```

### GPG sign git commits

```sh
git config --global user.signingKey "C5BC91DE79BC375F"
# git config --global user.signingKey "C7B2BB592C869901"
git config --global commit.gpgsign true
git config --global gpg.program $(which gpg)
```
