#!/bin/bash
yay -S hyprland-bin
sed -i "s\MODULES=(btrfs)\MODULES=(btrfs nvidia nvidia_modeset nvidia_uvm nvidia_drm)\g" /etc/mkinitcpio.conf
mkinitcpio --config /etc/mkinitcpio.conf --generate /boot/initramfs-custom.img
echo "options nvidia-drm modeset=1" >> /etc/modprobe.d/nvidia.conf
echo "#!/bin/sh

cd ~

export _JAVA_AWT_WM_NONREPARENTING=1
export XCURSOR_SIZE=24
export LIBVA_DRIVER_NAME=nvidia
export XDG_SESSION_TYPE=wayland
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export WLR_NO_HARDWARE_CURSORS=1

exec Hyprland" >> .local/bin/hyprland-start.sh
chmod +x .local/bin/hyprland-start.sh