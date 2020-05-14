# Setup Dev Environment

An shell script to set up my own prefered development tools and dotfiles.

## Compatibility

Works on Ubuntu 18.04 (bionic).

### XPS 15 7590 (2019 model) Notes

Installing Ubuntu on the XPS 15 was a bit of an adventure. I had to setup windows
in order to disable secure boot from the windows command prompt (otherwise the
hard disk was not visible to the ubuntu installer):

https://medium.com/@tylergwlum/my-journey-installing-ubuntu-18-04-on-the-dell-xps-15-7590-2019-756f738a6447

Once secure boot was disabled, the ubuntu 18.04 usb live stick no longer
worked, so I had to plug it into a windows laptop in order to rename
/boot/efi/grubx64.efi to mmx64.efi. (I couldn't get this to work on a linux
laptop, but I didn't try very hard).
https://askubuntu.com/questions/1085550/cant-install-ubuntu-18-10-on-xps-15-efi-boot-mmx64-efi-not-found

Then I continued with the instructions in the medium post to install the wifi and
bluetooth drivers. (Maybe these are duplicated by the ubuntu respin script below?)

Once 18.04 was installed, various graphics and power management stuff was
giving me trouble. This script resolved it:

* https://github.com/JackHack96/dell-xps-9570-ubuntu-respin

I set the graphics to use intel:

`sudo prime-select intel`

Additionally I determined that the dell 130W USB-C adapter is not compatible
with my USB-C breakout adapter.

To get double-finger click working as right-click, I had to install the synaptics driver:

`sudo apt install xserver-xorg-input-synaptics-hwe-18.04`

#### Zoom Woes

To get zoom to work properly with i3 i needed to use `i3-gnome` for my window
manager. I have no idea why this is required, but zoom works fine in gnome and
hangs (at high duty cycle, 5 secondish period, before any inputs are handled
or screen redraws) the entire window manager when using standalone i3.

* https://github.com/zxgio/i3-gnome-ubuntu18.04

I also ended up installing i3 4.18 from `sur5r`'s deb, versus the older one
that is packaged by 18.04. This did not fix the problem on its own, but I
didn't revert to the old i3 once my problems were solved.

```
$ /usr/lib/apt/apt-helper download-file https://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2020.02.03_all.deb keyring.deb SHA256:c5dd35231930e3c8d6a9d9539c846023fe1a08e4b073ef0d2833acd815d80d48
# dpkg -i ./keyring.deb
# echo "deb https://debian.sur5r.net/i3/ $(grep '^DISTRIB_CODENAME=' /etc/lsb-release | cut -f2 -d=) universe" >> /etc/apt/sources.list.d/sur5r-i3.list
# apt update
# apt install i3
```
