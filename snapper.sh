#!/bin/bash
pacman -S snapper snap-pac
umount /.snapshots/
rm -rf /.snapshots/
snapper -c root create-config /
sed -i 's\ALLOW_GROUPS=""\ALLOW_GROUPS="wheel"\g' /etc/snapper/configs/root
chmod a+rx /.snapshots/
systemctl enable --now snapper-timeline.timer
systemctl enable --now snapper-cleanup.timer
systemctl enable --now grub-btrfs.path
snapper -c root create -d "*** BASE SYS CONFIG  ***"