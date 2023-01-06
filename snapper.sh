#!/bin/bash
pacman -S snapper snap-pac inotify-tools grub-btrfs
umount /.snapshots/
rm -rf /.snapshots/
snapper -c root create-config /
sed -i 's\TIMELINE_LIMIT_DAILY="10"\TIMELINE_LIMIT_DAILY="2"\g' /etc/snapper/configs/root
sed -i 's\ALLOW_GROUPS=""\ALLOW_GROUPS="wheel"\g' /etc/snapper/configs/root
sed -i 's\TIMELINE_LIMIT_YEARLY="10"\TIMELINE_LIMIT_YEARLY="0"\g' /etc/snapper/configs/root
sed -i 's\NUMBER_LIMIT="50"\NUMBER_LIMIT="10"\g' /etc/snapper/configs/root
sed -i 's\TIMELINE_LIMIT_MONTHLY="10"\TIMELINE_LIMIT_MONTHLY="0"\g' /etc/snapper/configs/root
chmod a+rx /.snapshots/
systemctl enable --now snapper-timeline.timer
systemctl enable --now snapper-cleanup.timer
systemctl enable --now grub-btrfsd.service
snapper -c root create -d "*** BASE SYS CONFIG  ***"