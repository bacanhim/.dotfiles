#!/bin/bash
#theming, fonts and some background utils
pacman -S polkit-gnome gnome-keyring libsecret libgnome-keyring mpv pacman-contrib alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber blueman playerctl capitaine-cursors ttf-cascadia-code ttf-fira-code noto-fonts materia-gtk-theme papirus-icon-theme grub-theme-vimix zsh-theme-powerlevel10k zsh-syntax-highlighting zsh-autosuggestions ntfs-3g gvfs nfs-utils ntp unzip tar duf zip btop packagekit acpi acpi_call acpid --noconfirm
#utilities
pacman -S firefox teamspeak3 discord spotify-launcher flameshot arandr ranger neofetch stow
#xorg and video-drivers
pacman -S xorg xorg-server nvidia-dkms nvidia-utils nvidia-settings
#yay install not needed on endeavour
# cd /tmp && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si --noconfirm
#AUR PGK
yain chili-sddm-theme ttf-font-awesome-5 oh-my-zsh-git --noconfirm
#dotfiles
cd /home/bacanhim/.dotfiles && stow --target="$HOME" --no-folding .
cp -R /usr/share/grub/themes/* /boot/grub/themes/
#grub-theme
sed -i 's\Current=\Current=chili\g' /usr/lib/sddm/sddm.conf.d/default.conf #sddm theme
sed -i 's\#GRUB_THEME="/path/to/gfxtheme"\GRUB_THEME="/boot/grub/themes/Vimix/theme.txt"\g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

#laptop
# systemctl enable auto-cpufreq.service
# systemctl enable acpid
# yain auto-cpufreq

#sys auto-start
systemctl enable bluetooth
systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable ntpd.service