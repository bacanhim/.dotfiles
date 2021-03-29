#!/bin/bash
timedatectl set-ntp true
pacman -Syy reflector --noconfirm
reflector -c Portugal -a 6 --sort rate  --save /etc/pacman.d/mirrorlist
pacman -Syy
clear
lsblk
read -p "Qual e o disco a usar?" Disk
dd bs=512 if=/dev/zero of=/dev/"${Disk}" count=8192
dd bs=512 if=/dev/zero of=/dev/"${Disk}" count=8192 seek=$((`blockdev --getsz /dev/"${Disk}"` - 8192))
sgdisk --zap-all /dev/"${Disk}"
sgdisk -og /dev/"${Disk}"
sgdisk -n 0:0:+500MiB -t 0:ef00 -c 0:"boot" /dev/"${Disk}"
sgdisk -n 0:0:0 -t 0:8300 -c 0:"root" /dev/"${Disk}"
lsblk
sleep 5
clear
mkfs.fat -F32 /dev/"${Disk}"\1
modprobe dm-crypt
modprobe dm-mod
cryptsetup luksFormat -v -s 512 -h sha512 /dev/"${Disk}"\2
cryptsetup open /dev/"${Disk}"\2 lynx
mkfs.btrfs -L root /dev/mapper/lynx
mount /dev/mapper/lynx /mnt
btrfs su create /mnt/@
btrfs su create /mnt/@home
btrfs su create /mnt/@var
btrfs su create /mnt/@srv
btrfs su create /mnt/@opt
btrfs su create /mnt/@tmp
btrfs su create /mnt/@swap
btrfs su create /mnt/@.snapshots
umount /mnt
mount -o noatime,compress=zstd,space_cache,subvol=@ /dev/mapper/lynx /mnt
mkdir /mnt/{boot,home,var,srv,tmp,opt,swap,.snapshots}
mount -o noatime,compress=zstd,space_cache,subvol=@home /dev/mapper/lynx /mnt/home
mount -o noatime,compress=zstd,space_cache,subvol=@srv /dev/mapper/lynx /mnt/srv
mount -o noatime,compress=zstd,space_cache,subvol=@tmp /dev/mapper/lynx /mnt/tmp
mount -o noatime,compress=zstd,space_cache,subvol=@opt /dev/mapper/lynx /mnt/opt
mount -o noatime,compress=zlib,space_cache,subvol=@.snapshots /dev/mapper/lynx /mnt/.snapshots
mount -o nodatacow,subvol=@swap /dev/mapper/lynx /mnt/swap
mount -o nodatacow,subvol=@var /dev/mapper/lynx /mnt/var
mount /dev/"${Disk}"\1 /mnt/boot
btrfs subvolume list /mnt
sleep 15
pacstrap /mnt base base-devel linux linux-firmware nano intel-ucode btrfs-progs reflector --noconfirm
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
sleep 5
clear
arch-chroot /mnt truncate -s 0 /swap/swapfile
arch-chroot /mnt chattr +C /swap/swapfile
arch-chroot /mnt btrfs property set swap/swapfile compression none
arch-chroot /mnt dd if=dev/zero of=/swap/swapfile bs=1G count=16 status=progress
arch-chroot /mnt chmod 600 /swap/swapfile
arch-chroot /mnt mkswap /swap/swapfile
arch-chroot /mnt swapon /swap/swapfile
arch-chroot /mnt echo /swap/swapfile none swap defaults 0 0 >> /mnt/etc/fstab
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Lisbon /etc/localtime
arch-chroot /mnt hwclock --systohc
arch-chroot /mnt sed -i "s/#en_US.UTF-8/en_US.UTF-8/g" /etc/locale.gen
arch-chroot /mnt locale-gen
arch-chroot /mnt echo LANG=en_US.UTF-8 >> /mnt/etc/locale.conf
arch-chroot /mnt echo lynx >> /mnt/etc/hostname
arch-chroot /mnt echo "127.0.0.1       localhost lynx" >> /mnt/etc/hosts
arch-chroot /mnt echo "::1             localhost lynx " >> /mnt/etc/hosts
sleep 5
clear
arch-chroot /mnt reflector -c Portugal -a 6 --sort rate  --save /etc/pacman.d/mirrorlist
arch-chroot /mnt pacman -S grub grub-btrfs efibootmgr networkmanager network-manager-applet wpa_supplicant dialog os-prober mtools dosfstools linux-headers git xdg-utils xdg-user-dirs --noconfirm
arch-chroot /mnt sed -i -e 's\GRUB_CMDLINE_LINUX=""\GRUB_CMDLINE_LINUX="cryptdevice=/dev/'"${Disk}"'2:lynx"\g' /etc/default/grub
arch-chroot /mnt sed -i "s\MODULES=()\MODULES=(btrfs)\g" /etc/mkinitcpio.conf
arch-chroot /mnt sed -i "s\HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)\HOOKS=(base udev autodetect modconf block encrypt filesystems keyboard fsck)\g" /etc/mkinitcpio.conf
arch-chroot /mnt mkinitcpio -p linux
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB /dev/"${Disk}"\1
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
arch-chroot /mnt systemctl enable NetworkManager
sleep 5
clear
arch-chroot /mnt sed -i "s\# %wheel ALL=(ALL) ALL\%wheel ALL=(ALL) ALL\g" /etc/sudoers
arch-chroot /mnt pacman -S snapper ntfs-3g --noconfirm
arch-chroot /mnt systemctl enable snapper-timeline.timer
arch-chroot /mnt systemctl enable snapper-cleanup.timer
arch-chroot /mnt systemctl enable grub-btrfs.path
sleep 5
clear
arch-chroot /mnt pacman -Syu
arch-chroot /mnt pacman -S xorg xorg-server lightdm lightdm-gtk-greeter openssh --noconfirm
arch-chroot /mnt systemctl enable lightdm
arch-chroot /mnt pacman -S nvidia nvidia-utils nvidia-settings --noconfirm
arch-chroot /mnt pacman -S alacritty perl-json-xs perl-anyevent-i3 atom ranger pacman-contrib python-dbus dunst rofi i3-gaps neofetch stow playerctl capitaine-cursors ttf-font-awesome flameshot thunar feh zsh code firefox teamspeak3 materia-gtk-theme papirus-icon-theme --noconfirm
sleep 15
clear
echo "ROOT PASSWORD"
arch-chroot /mnt passwd
arch-chroot /mnt useradd -mG wheel bacanhim -s /usr/bin/zsh
echo "BACANHIM PASSWORD"
arch-chroot /mnt passwd bacanhim
arch-chroot /mnt chsh -s $(which zsh)
arch-chroot /mnt runuser -l bacanhim -c 'git config --global user.name "Helder Bacanhim"'
arch-chroot /mnt runuser -l bacanhim -c 'git config --global user.email "6317993-bacanhim@users.noreply.gitlab.com"'
arch-chroot /mnt runuser -l bacanhim -c 'ssh-keygen -t ed25519 -C "Gitlab"'
arch-chroot /mnt echo "bacanhim ALL=(ALL) NOPASSWD:ALL" >> /mnt/etc/sudoers
arch-chroot /mnt runuser -l bacanhim -c "cd /tmp && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm"
arch-chroot /mnt runuser -l bacanhim -c 'yay -S polybar gksu snapper-gui-git consolas-font noto-fonts-main betterlockscreen-git spotify --noconfirm'
echo "DOWNLOADING AND APPLYING DOTFILES"
sleep 5
arch-chroot /mnt runuser -l bacanhim -c "cd /home/bacanhim/ && git clone https://gitlab.com/bacanhim/.dotfiles.git"
arch-chroot /mnt runuser -l bacanhim -c 'cd /home/bacanhim/.dotfiles && stow --target="$HOME" --no-folding .'
arch-chroot /mnt sed -i "s\bacanhim ALL=(ALL) NOPASSWD:ALL\ \g" /etc/sudoers
echo "ALL DONE REBOOTING"
sleep 10
umount -a
sleep 2
reboot
