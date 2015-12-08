# Setup Dev Environment

An Ansible playbook to set up my own prefered development tools and dotfiles.

## Requirements

This playbook was written for Ansible version 1.9.

You need to create a `hosts` file, or change the `ansible.cfg` to point at an
inventory.

## Compatibility

Currently only tested against a clean Fedora 23 install. Prerequisites:

- Add an SSH key to `authorized_hosts`
- `systemctl enable sshd.service`

Then run `ansible-playbook common.yml -l <host>`.
