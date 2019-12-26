#/bin/sh

sudo pacman -S --noconfirm \
	binutils \
	make \
	gcc \
	pkg-config \
	fakeroot

echo -n "Specify where to clone yay: [./]"
read CLONE_DIR

if [[ -z CLONE_DIR ]]; then
	cd $CLONE_DIR
fi

git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
