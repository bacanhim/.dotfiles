#!/bin/bash
sudo su
pacman -S bspwm sxhkd picom xfce4-notifyd polybar python-dbus sddm rofi alacritty thunar feh
systemctl enable sddm.service