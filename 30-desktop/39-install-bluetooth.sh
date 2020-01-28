#!/bin/sh

sudo pacman -S --no-confirm \
	bluez \
	bluez-utils \
	pulseaudio-bluetooth

sudo systemctl enable bluetooth
sudo systemctl start bluetooth
