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
