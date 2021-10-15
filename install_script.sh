#!/bin/bash
timedatectl set-ntp true
pacman -Sy
clear
lsblk
read -p "Qual e o disco a usar?" Disk
dd bs=512 if=/dev/zero of=/dev/"${Disk}" count=8192
dd bs=512 if=/dev/zero of=/dev/"${Disk}" count=8192 seek=$((`blockdev --getsz /dev/"${Disk}"` - 8192))
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
btrfs su create /mnt/@swap
umount /mnt
mount -o noatime,compress=zstd,discard=async,space_cache=v2,subvol=@ /dev/mapper/lynx /mnt
mkdir /mnt/{boot,home,var,srv,tmp,opt,swap}
mount -o noatime,compress=zstd,discard=async,space_cache=v2,subvol=@home /dev/mapper/lynx /mnt/home
mount -o noatime,compress=zstd,discard=async,space_cache=v2,subvol=@srv /dev/mapper/lynx /mnt/srv
mount -o noatime,compress=zstd,discard=async,space_cache=v2,subvol=@tmp /dev/mapper/lynx /mnt/tmp
mount -o noatime,compress=zstd,discard=async,space_cache=v2,subvol=@opt /dev/mapper/lynx /mnt/opt
mount -o nodatacow,discard=async,subvol=@swap /dev/mapper/lynx /mnt/swap
mount -o nodatacow,discard=async,subvol=@var /dev/mapper/lynx /mnt/var
mount /dev/"${Disk}"\1 /mnt/boot/
pacstrap /mnt base base-devel linux linux-firmware linux-headers nano intel-ucode btrfs-progs reflector --noconfirm
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt truncate -s 0 /swap/swapfile
arch-chroot /mnt chattr +C /swap/swapfile
arch-chroot /mnt btrfs property set swap/swapfile compression none
arch-chroot /mnt dd if=dev/zero of=/swap/swapfile bs=1G count=8 status=progress
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
arch-chroot /mnt pacman -S zsh openssh efibootmgr networkmanager network-manager-applet wpa_supplicant dialog os-prober mtools dosfstools vim git xdg-utils xdg-user-dirs --noconfirm
arch-chroot /mnt sed -i "s\MODULES=()\MODULES=(btrfs)\g" /etc/mkinitcpio.conf
arch-chroot /mnt sed -i "s\BINARIES=()\BINARIES=(/usr/bin/btrfs)\g" /etc/mkinitcpio.conf
arch-chroot /mnt sed -i "s\HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)\HOOKS=(base udev plymouth autodetect keyboard keymap modconf block plymouth-encrypt filesystems fsck)\g" /etc/mkinitcpio.conf
arch-chroot /mnt mkinitcpio -p linux
arch-chroot /mnt bootctl --path=/boot install
arch-chroot /mnt echo 'title Arch Linux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options cryptdevice=/dev/'"${Disk}"'2:lynx root=/dev/mapper/lynx rootflags=subvol=@ rw intel_pstate=no_hwp quiet splash' >> /mnt/boot/loader/entries/arch.conf
arch-chroot /mnt sed -i "s\# %wheel ALL=(ALL) ALL\%wheel ALL=(ALL) ALL\g" /etc/sudoers
arch-chroot /mnt chsh -s $(which zsh)
arch-chroot /mnt useradd -mG wheel bacanhim -s $(which zsh)
echo "BACANHIM PASSWORD"
arch-chroot /mnt passwd bacanhim
arch-chroot /mnt echo "bacanhim ALL=(ALL) NOPASSWD:ALL" >> /mnt/etc/sudoers
arch-chroot /mnt runuser -l bacanhim -c 'ssh-keygen -t ed25519 -C "Gitlab"'
arch-chroot /mnt pacman -S bitwarden bspwm sxhkd discord mpv arandr picom noto-fonts ntfs-3g polkit-gnome avahi gvfs nfs-utils inetutils ntp unzip tar zip unoconv dnsutils htop bluez bluez-utils cups cockpit packagekit alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack rsync reflector acpi acpi_call tlp virt-manager qemu qemu-arch-extra edk2-ovmf bridge-utils dnsmasq vde2 openbsd-netcat iptables-nft ipset firewalld ebtables flatpak nss-mdns acpid nfs-utils xorg xorg-server nvidia nvidia-utils nvidia-settings alacritty ranger pacman-contrib python-dbus dunst rofi neofetch stow playerctl capitaine-cursors ttf-font-awesome flameshot thunar feh code firefox teamspeak3 ttf-fira-code materia-gtk-theme papirus-icon-theme
arch-chroot /mnt runuser -l bacanhim -c "cd /tmp && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm"
arch-chroot /mnt runuser -l bacanhim -c 'yay -S polybar plymouth plymouth-theme-arch-charge noto-color-emoji-fontconfig ly-git ttf-unifont consolas-font zathura-git betterlockscreen-git timeshift timeshift-autosnap auto-cpufreq-git spotify oh-my-zsh-git zsh-theme-powerlevel10k-git zsh-syntax-highlighting-git zsh-autosuggestions-git --noconfirm'
echo "DOWNLOADING AND APPLYING DOTFILES"
arch-chroot /mnt runuser -l bacanhim -c "cd /home/bacanhim/ && git clone https://gitlab.com/bacanhim/.dotfiles.git"
arch-chroot /mnt runuser -l bacanhim -c 'cd /home/bacanhim/.dotfiles && stow --target="$HOME" --no-folding .'
arch-chroot /mnt runuser -l bacanhim -c 'sudo plymouth-set-default-theme -R arch-charge'
arch-chroot /mnt sed -i "s\bacanhim ALL=(ALL) NOPASSWD:ALL\ \g" /etc/sudoers
arch-chroot /mnt usermod -aG libvirt bacanhim
arch-chroot /mnt systemctl enable ly.service
arch-chroot /mnt systemctl enable NetworkManager
#arch-chroot /mnt systemctl enable bluetooth
#arch-chroot /mnt systemctl enable cups.service
arch-chroot /mnt systemctl enable sshd
arch-chroot /mnt systemctl enable avahi-daemon
#arch-chroot /mnt systemctl enable tlp
arch-chroot /mnt systemctl enable reflector.timer
arch-chroot /mnt systemctl enable fstrim.timer
arch-chroot /mnt systemctl enable libvirtd
arch-chroot /mnt systemctl enable --now firewalld
arch-chroot /mnt systemctl enable acpid
arch-chroot /mnt systemctl enable auto-cpufreq
#arch-chroot /mnt systemctl enable cockpit.socket
arch-chroot /mnt systemctl enable ntpd.service
arch-chroot /mnt firewall-cmd --add-service libvirt --zone=libvirt --permanent

echo "ALL DONE REBOOTING"
sleep 2
reboot
