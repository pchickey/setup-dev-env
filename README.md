# Setup Dev Environment

An shell script to set up my own prefered development tools and dotfiles.

## Compatibility

Works on MacOS and Ubuntu 24.04

## Manual steps

### Zsh default shell

chsh -s $(which zsh)

### SSH private keys

The actual private keys are resident on the yubikey, but you still need a
private key file, not in this repo out of exceeding paranoia. chmod them 600.

### Import GPG keys

gpg --import yubikey-5c-1-public.pgp
gpg --list-public-keys
gpg --edit-key (fingerprint) trust 5
