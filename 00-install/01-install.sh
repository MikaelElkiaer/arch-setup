#!/bin/sh

set -o errexit

loadkeys dk-latin1
timedatectl set-ntp true

###########
# CONFIGURE
###########
PASSWORD_ROOT=""
while [ -z "$PASSWORD_ROOT" ]; do
    echo -n "Set ROOT password: "
    read -s -r _TEMP_PWORD; echo
    echo -n "Confirm ROOT password: "
    read -s -r _TEMP_PWORD_2; echo
    if [ "$_TEMP_PWORD" == "$_TEMP_PWORD_2" ]; then PASSWORD_ROOT="$_TEMP_PWORD"; fi
done
echo -n "Set username: "
read USERNAME
PASSWORD_USER=""
while [ -z "$PASSWORD_USER" ]; do
    echo -n "Set USER password: "
    read -s -r _TEMP_PWORD; echo
    echo -n "Confirm USER password: "
    read -s -r _TEMP_PWORD_2; echo
    if [ "$_TEMP_PWORD" == "$_TEMP_PWORD_2" ]; then PASSWORD_USER="$_TEMP_PWORD"; fi
done
echo -n "Set hostname: "
read HOSTNAME
echo -n "Set disk: "
read DISK_NAME
echo -n "Set swap size: "
read SWAP_SIZE

############
# PARTITIONS
############
if [[ ${DISK_NAME} =~ "^.*[0-9]$" ]]; then
	DISK_NAME_P=${DISK_NAME}p
else
	DISK_NAME_P=${DISK_NAME}
fi

sgdisk -o ${DISK_NAME} -g
sgdisk -n 1:0:+1M -t 1:ef02 -c 1:"BIOS Boot Partition" ${DISK_NAME}
sgdisk -n 2:0:+550M -t 2:ef00 -c 2:"EFI System Partition" ${DISK_NAME}
sgdisk -n 3:0:+200M -t 3:8300 -c 3:"Boot Partition" ${DISK_NAME}
sgdisk -n 4:0:-$SWAP_SIZE -t 4:8300 -c 4:"Root Partition" ${DISK_NAME}
sgdisk -n 5:0:0 -t 5:8200 -c 5:"Swap Partition" ${DISK_NAME}
sgdisk -p ${DISK_NAME}

mkswap ${DISK_NAME_P}5
mkfs.ext4 ${DISK_NAME_P}4
mount ${DISK_NAME_P}4 /mnt
mkdir /mnt/boot
mkfs.ext4 ${DISK_NAME_P}3
mount ${DISK_NAME_P}3 /mnt/boot
mkfs.fat -F32 ${DISK_NAME_P}2
mkdir /mnt/efi
mount ${DISK_NAME_P}2 /mnt/efi

###########
# BOOTSTRAP
###########
pacstrap /mnt base linux-lts linux-firmware grub efibootmgr vim sudo zsh netctl dialog wpa_supplicant dhcpcd

genfstab -U /mnt >> /mnt/etc/fstab

###############
### ARCH-CHROOT
###############
arch-chroot /mnt <<- CHROOTEOF
	set -o errexit
	
	# localization
	ln -sf /usr/share/zoneinfo/Europe/Copenhagen /etc/localtime
	hwclock --systohc
	sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
	sed -i 's/#en_DK.UTF-8 UTF-8/en_DK.UTF-8 UTF-8/g' /etc/locale.gen
	locale-gen
	echo LANG=en_DK.UTF-8 > /etc/locale.conf
	echo KEYMAP=dk-latin1 > /etc/vconsole.conf
	
	# hostnames
	echo $HOSTNAME > /etc/hostname
	cat << HOSTSEOF >> /etc/hosts
		127.0.0.1	  localhost
		::1		      localhost
		127.0.1.1	  $HOSTNAME.localdomain	$HOSTNAME
	HOSTSEOF
	
	# ucode
	cat /proc/cpuinfo | grep -q GenuineIntel && pacman -S intel-ucode --noconfirm
	cat /proc/cpuinfo | grep -q AuthenticAMD && pacman -S amd-ucode --noconfirm
	
	# user
	sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers
	useradd -m -G wheel -s /bin/zsh $USERNAME
	echo "$USERNAME:$PASSWORD_USER" | /usr/sbin/chpasswd
	
	# bootloader
	mkdir /boot/grub
	grub-mkconfig -o /boot/grub/grub.cfg
	grub-install --target=i386-pc --recheck ${DISK_NAME}
	mkinitcpio -p linux-lts
	
	echo "root:$PASSWORD_ROOT" | /usr/sbin/chpasswd
CHROOTEOF
