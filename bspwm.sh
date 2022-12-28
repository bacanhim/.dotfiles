#!/bin/bash
sudo su
pacman -S gnome-keyring libsecret libgnome-keyring picom mpv pacman-contrib xfce4-notifyd polybar python-dbus arandr spotify-launcher ntfs-3g gvfs nfs-utils ntp unzip tar duf zip htop packagekit acpi acpi_call tlp acpid sddm polkit-gnome xorg xorg-server nvidia nvidia-utils nvidia-settings alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack blueman playerctl flameshot bspwm sxhkd rofi alacritty ranger neofetch stow thunar feh firefox teamspeak3 discord capitaine-cursors ttf-cascadia-code ttf-fira-code noto-fonts materia-gtk-theme papirus-icon-theme grub-theme-vimix --noconfirm
cd /tmp && git clone https://aur.archlinux.org/paru-bin.git && cd paru-bin && makepkg -si --noconfirm
paru -S auto-cpufreq visual-studio-code-bin chili-sddm-theme betterlockscreen-git timeshift-bin timeshift-autosnap oh-my-zsh-git zsh-theme-powerlevel10k-git zsh-syntax-highlighting-git zsh-autosuggestions-git ttf-font-awesome-5 --noconfirm
echo "DOWNLOADING AND APPLYING DOTFILES"
cd /home/bacanhim/ && git clone https://github.com/bacanhim/.dotfiles.git
cd /home/bacanhim/.dotfiles && stow --target="$HOME" --no-folding .
cp -R /usr/share/grub/themes/* /boot/grub/themes/ #not working yet
sed -i 's\#GRUB_THEME="/path/to/gfxtheme"\GRUB_THEME="/boot/grub/themes/Vimix/theme.txt"\g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
sed -i 's\Current=\Current=chili\g' /usr/lib/sddm/sddm.conf.d/default.conf
sed -i "s\bacanhim ALL=(ALL) NOPASSWD:ALL\ \g" /etc/sudoers
systemctl enable sddm.service
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable acpid
systemctl enable ntpd.service
systemctl enable auto-cpufreq.service
echo "ALL DONE REBOOTING"
sleep 2
reboot