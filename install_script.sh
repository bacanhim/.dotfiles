#!/bin/bash
timedatectl set-ntp true
pacman -Sy
clear
lsblk
read -p "Qual e o disco a usar?" Disk
sed -i "s/#Color/Color/g" /etc/pacman.conf
sed -i "s/#ParallelDownloads = 5/ParallelDownloads = 5/g" /etc/pacman.conf
dd bs=512 if=/dev/zero of=/dev/"${Disk}" count=8192
dd bs=512 if=/dev/zero of=/dev/"${Disk}" count=8192 seek=$(($(blockdev --getsz /dev/"${Disk}") - 8192))
sgdisk --zap-all /dev/"${Disk}"
sgdisk -og /dev/"${Disk}"
sgdisk -n 0:0:+650MiB -t 0:ef00 -c 0:efi /dev/"${Disk}"
sgdisk -n 0:0:0 -t 0:8300 -c 0:root /dev/"${Disk}"
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
umount /mnt
mount -o noatime,compress=zstd,discard=async,space_cache=v2,subvol=@ /dev/mapper/lynx /mnt
mkdir /mnt/{boot,home,var,srv,tmp,opt}
mount -o noatime,compress=zstd,discard=async,space_cache=v2,subvol=@home /dev/mapper/lynx /mnt/home
mount -o noatime,compress=zstd,discard=async,space_cache=v2,subvol=@srv /dev/mapper/lynx /mnt/srv
mount -o noatime,compress=zstd,discard=async,space_cache=v2,subvol=@tmp /dev/mapper/lynx /mnt/tmp
mount -o noatime,compress=zstd,discard=async,space_cache=v2,subvol=@opt /dev/mapper/lynx /mnt/opt
mount -o nodatacow,discard=async,subvol=@var /dev/mapper/lynx /mnt/var
mount /dev/"${Disk}"\1 /mnt/boot/
pacstrap /mnt base base-devel linux linux-firmware linux-headers git vim intel-ucode btrfs-progs reflector rsync --noconfirm
arch-chroot /mnt sed -i "s/#Color/Color/g" /etc/pacman.conf
arch-chroot /mnt sed -i "s/#ParallelDownloads = 5/ParallelDownloads = 5/g" /etc/pacman.conf
genfstab -U /mnt >>/mnt/etc/fstab
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Lisbon /etc/localtime
arch-chroot /mnt hwclock --systohc
arch-chroot /mnt sed -i "s/#en_US.UTF-8/en_US.UTF-8/g" /etc/locale.gen
arch-chroot /mnt locale-gen
arch-chroot /mnt echo LANG=en_US.UTF-8 >>/mnt/etc/locale.conf
arch-chroot /mnt echo lynx >>/mnt/etc/hostname
arch-chroot /mnt echo "127.0.0.1       localhost lynx" >>/mnt/etc/hosts
arch-chroot /mnt echo "::1             localhost lynx " >>/mnt/etc/hosts
arch-chroot /mnt pacman -S zsh openssh grub grub-btrfs efibootmgr networkmanager network-manager-applet wpa_supplicant dialog os-prober mtools dosfstools xdg-utils xdg-user-dirs --noconfirm
arch-chroot /mnt sed -i "s\MODULES=()\MODULES=(btrfs)\g" /etc/mkinitcpio.conf
arch-chroot /mnt sed -i "s\BINARIES=()\BINARIES=(/usr/bin/btrfs)\g" /etc/mkinitcpio.conf
arch-chroot /mnt sed -i "s\HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)\HOOKS=(base udev autodetect keyboard keymap modconf block encrypt filesystems fsck)\g" /etc/mkinitcpio.conf
arch-chroot /mnt sed -i 's\GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"\GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet cryptdevice=/dev/'"${Disk}"'2:lynx root=/dev/mapper/lynx"\g' /etc/default/grub
arch-chroot /mnt mkinitcpio -p linux
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
arch-chroot /mnt sed -i "s\# %wheel ALL=(ALL:ALL) ALL\%wheel ALL=(ALL:ALL) ALL\g" /etc/sudoers
arch-chroot /mnt chsh -s $(which zsh)
arch-chroot /mnt useradd -mG wheel bacanhim -s $(which zsh)
echo "BACANHIM PASSWORD"
arch-chroot /mnt passwd bacanhim
arch-chroot /mnt echo "bacanhim ALL=(ALL) NOPASSWD:ALL" >>/mnt/etc/sudoers
arch-chroot /mnt runuser -l bacanhim -c 'ssh-keygen -t ed25519 -C "Gitlab"'
arch-chroot /mnt pacman -S mpv pacman-contrib polybar python-dbus arandr ntfs-3g gvfs nfs-utils ntp unzip tar duf zip htop packagekit acpi acpi_call tlp acpid sddm polkit-gnome xorg xorg-server nvidia nvidia-utils nvidia-settings alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack blueman playerctl flameshot bspwm sxhkd rofi alacritty ranger neofetch stow thunar feh firefox teamspeak3 discord capitaine-cursors ttf-cascadia-code ttf-fira-code noto-fonts materia-gtk-theme papirus-icon-theme --noconfirm
arch-chroot /mnt runuser -l bacanhim -c "cd /tmp && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si --noconfirm"
arch-chroot /mnt runuser -l bacanhim -c 'paru -S betterlockscreen-git timeshift timeshift-autosnap spotify-tui oh-my-zsh-git zsh-theme-powerlevel10k-git zsh-syntax-highlighting-git zsh-autosuggestions-git --noconfirm'
echo "DOWNLOADING AND APPLYING DOTFILES"
arch-chroot /mnt runuser -l bacanhim -c "cd /home/bacanhim/ && git clone https://github.com/bacanhim/.dotfiles.git"
arch-chroot /mnt runuser -l bacanhim -c 'cd /home/bacanhim/.dotfiles && stow --target="$HOME" --no-folding .'
arch-chroot /mnt cp -R /usr/share/grub/themes/* /boot/grub/themes/
arch-chroot /mnt echo 'GRUB_THEME="/boot/grub/themes/Vimix/theme.txt"' >>/etc/default/grub
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
arch-chroot /mnt sed -i "s\bacanhim ALL=(ALL) NOPASSWD:ALL\ \g" /etc/sudoers
arch-chroot /mnt systemctl enable sddm.service
arch-chroot /mnt systemctl enable NetworkManager
arch-chroot /mnt systemctl enable bluetooth
arch-chroot /mnt systemctl enable reflector.timer
arch-chroot /mnt systemctl enable fstrim.timer
arch-chroot /mnt systemctl enable acpid
arch-chroot /mnt systemctl enable ntpd.service
echo "ALL DONE REBOOTING"
sleep 2
reboot
