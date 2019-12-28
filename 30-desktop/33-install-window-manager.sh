#/bin/sh

sudo pacman -S --noconfirm \
	picom \
	autorandr \
	i3-gaps \
	i3lock \
	rofi \
	feh \
	lxappearance \
	gnome-terminal \
	powerline \
	powerline-fonts \
	libnotify \
	dunst

yay -S --noconfirm aur/polybar
yay -S --noconfirm aur/nerd-fonts-dejavu-complete
