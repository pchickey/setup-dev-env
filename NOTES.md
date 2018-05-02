## XFCE4

In Settings -> Session and Startup -> Application Autostart, add a "caps lock to
control" app:

```
setxkbmap -option 'ctrl:nocaps'
```


## Firefox
toggle this setting so Alt doesnt cause the menu bar to show up
about:config?filter=ui.key.menuAccessKeyFocuses

