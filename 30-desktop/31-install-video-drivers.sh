#/bin/sh

# Install packages
sudo pacman -S nvidia optimus-manager brightnessctl

# Set up optimus-manager
echo 'Option "Backlight" "intel_backlight"' >> /etc/optimus-manager/xorg-intel.conf

sudo systemctl enable optimus-manager
sudo systemctl start optimus-manager

optimus-manager --set-startup hybrid

# Set up nvidia power management
sudo sh -c "cat <<- EOL > /lib/udev/rules.d/80-nvidia-pm.rules
# Remove NVIDIA USB xHCI Host Controller devices, if present
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{remove}="1"

# Remove NVIDIA USB Type-C UCSI devices, if present
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{remove}="1"

# Remove NVIDIA Audio devices, if present
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{remove}="1"

# Enable runtime PM for NVIDIA VGA/3D controller devices on driver bind
ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="auto"
ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="auto"

# Disable runtime PM for NVIDIA VGA/3D controller devices on driver unbind
ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="on"
ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="on"
EOL"

echo 'options nvidia "NVreg_DynamicPowerManagement=0x02"' > /etc/modprobe.d/nvidia.conf

# enable brightnessctl for user
sudo usermod -aG video $USER

# reboot
echo -n "Reboot now? [Y/n]
read REBOOT_NOW
REBOOT_NOW=$(echo $REBOOT_NOW | tr '[A-Z]' '[a-z]')
if [[ ${REBOOT_NOW:-y} == y ]]; then
	sudo systemctl reboot
fi
