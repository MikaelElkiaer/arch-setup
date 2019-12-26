#/bin/sh

sudo pacman -S --noconfirm \
	xorg-server \
	xorg-apps \
	xorg-xinit \
	xorg-xrandr

echo -n "Set x11 keyboard layout: [dk]"
read KEYBOARD_LAYOUT
echo -n "Set x11 keyboard model: [pc105]"
read KEYBOARD_MODEL
sudo localectl --no-convert set-x11-keymap ${KEYBOARD_LAYOUT:-dk} ${KEYBOARD_MODEL:-pc105}
