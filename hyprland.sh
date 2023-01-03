#!/bin/bash
yay -S hyprland-bin
sed -i "s\MODULES=(btrfs)\MODULES=(btrfs nvidia nvidia_modeset nvidia_uvm nvidia_drm)\g" /etc/mkinitcpio.conf
mkinitcpio --config /etc/mkinitcpio.conf --generate /boot/initramfs-custom.img
echo "options nvidia-drm modeset=1" >> /etc/modprobe.d/nvidia.conf