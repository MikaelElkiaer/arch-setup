#/bin/sh

yay -S --noconfirm aur/nordic-theme-git
yay -S --noconfirm aur/zafiro-icon-theme
yay -S --noconfirm aur/ant-dracula-gtk-theme

sudo pacman -S --noconfirm dconf util-linux

echo -n "Specify where to clone: [./]"
read CLONE_DIR

if [[ -z CLONE_DIR ]]; then
	cd $CLONE_DIR
fi

git clone https://github.com/arcticicestudio/nord-gnome-terminal.git
cd nord-gnome-terminal/src
./nord.sh

cd ../..

git clone https://github.com/GalaticStryder/gnome-terminal-colors-dracula
cd gnome-terminal-colors-dracula
./install.sh
