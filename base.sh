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
btrfs su create /mnt/@snapshots
umount /mnt
mount -o noatime,compress=zstd,discard=async,space_cache=v2,subvol=@ /dev/mapper/lynx /mnt
mkdir /mnt/{boot,home,var,.snapshots}
mount -o noatime,compress=zstd,discard=async,space_cache=v2,subvol=@home /dev/mapper/lynx /mnt/home
mount -o noatime,compress=zstd,discard=async,space_cache=v2,subvol=@snapshots /dev/mapper/lynx /mnt/.snapshots
mount -o noatime,compress=zstd,discard=async,space_cache=v2,subvol=@var /dev/mapper/lynx /mnt/var
mount /dev/"${Disk}"\1 /mnt/boot/
pacstrap /mnt base base-devel linux linux-firmware linux-headers git vim intel-ucode amd-ucode btrfs-progs reflector rsync --noconfirm
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
arch-chroot /mnt pacman -S zsh openssh grub grub-btrfs efibootmgr networkmanager wpa_supplicant dialog os-prober mtools dosfstools xdg-utils xdg-user-dirs --noconfirm
arch-chroot /mnt useradd -mG wheel bacanhim -s $(which zsh)
echo "BACANHIM PASSWORD"
arch-chroot /mnt passwd bacanhim
arch-chroot /mnt sed -i "s\MODULES=()\MODULES=(btrfs)\g" /etc/mkinitcpio.conf
arch-chroot /mnt sed -i "s\BINARIES=()\BINARIES=(/usr/bin/btrfs)\g" /etc/mkinitcpio.conf
arch-chroot /mnt sed -i "s\HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)\HOOKS=(base udev autodetect keyboard keymap modconf block encrypt filesystems fsck)\g" /etc/mkinitcpio.conf
arch-chroot /mnt sed -i 's\GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"\GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet cryptdevice=/dev/'"${Disk}"'2:lynx root=/dev/mapper/lynx"\g' /etc/default/grub
arch-chroot /mnt mkinitcpio -p linux
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --removable
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
arch-chroot /mnt sed -i "s\# %wheel ALL=(ALL:ALL) ALL\%wheel ALL=(ALL:ALL) ALL\g" /etc/sudoers
arch-chroot /mnt chsh -s $(which zsh)
arch-chroot /mnt echo "bacanhim ALL=(ALL) NOPASSWD:ALL" >>/mnt/etc/sudoers
arch-chroot /mnt runuser -l bacanhim -c 'ssh-keygen -t ed25519 -C "Gitlab"'
arch-chroot /mnt systemctl enable NetworkManager
arch-chroot /mnt sed -i "s\bacanhim ALL=(ALL) NOPASSWD:ALL\ \g" /etc/sudoers
echo "DOWNLOADING DOTFILES"
arch-chroot /mnt cd /home/bacanhim/ && git clone https://github.com/bacanhim/.dotfiles.git
echo "ALL DONE REBOOTING"
sleep 2
reboot
