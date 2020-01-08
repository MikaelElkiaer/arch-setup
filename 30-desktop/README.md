# Install display manager (LightDM)

Install packages `lightdm`, `lightdm-gtk-greeter`, `light-locker`.

Set greeter in `/etc/lightdm/lightdm.conf`:

```
[Seat:*]
...
greeter-session=lightdm-gtk-greeter
...
```

Set GTK theme, background, and more for greeter in `/etc/lightdm/lightdm-gtk-greeter.conf`.

Enable `lightdm.service`.

Start light-locker by adding `exec light-locker` in `.xinitrc` before starting the window manager.
