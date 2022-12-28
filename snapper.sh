#!/bin/bash
umount /.snapshots/
rm -rf /.snapshots/
snapper -c root create-config /
sed -i 's\ALLOW_USERS=""\ALLOW_USERS="bacanhim"\g' /etc/snapper/configs/root
chmod a+rx /.snapshots/
systemctl enable --now snapper-timeline.timer
systemctl enable --now snapper-cleanup.timer
systemctl enable --now grub-btrfs.path