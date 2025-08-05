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

### GPG forwarding

GPG agent can be forwarded: https://wiki.gnupg.org/AgentForwarding

In the host macbook, I needed to add this to `.profile`:

```sh
# In order for gpg to find gpg-agent, gpg-agent must be running, and there must be an env
# variable pointing GPG to the gpg-agent socket. This little script, which must be sourced
# in your shell's init script (ie, .bash_profile, .zshrc, whatever), will either start
# gpg-agent or set up the GPG_AGENT_INFO variable if it's already running.

# Add the following to your shell init to set up gpg-agent automatically for every shell
if [ -f ~/.gnupg/.gpg-agent-info ] && [ -n "$(pgrep gpg-agent)" ]; then
    source ~/.gnupg/.gpg-agent-info
    export GPG_AGENT_INFO
else
    eval $(gpg-agent --daemon --write-env-file ~/.gnupg/.gpg-agent-info)
fi
```

On the target ubuntu machine, I needed to add this to `.profile`:

```sh
if command -v gpgconf; then
    gpgconf --create-socketdir
fi
```

and this setting to `/etc/ssh/sshd_config`:

```
StreamLocalBindUnlink yes
```

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
