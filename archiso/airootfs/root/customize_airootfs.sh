#!/usr/bin/env bash
# shellcheck disable=SC2016
#
# Aite OS — first-stage chroot customization
#
# This script is executed by mkarchiso INSIDE the airootfs chroot at build
# time. Use it for things that must happen as root in the target system:
#   * generating locale + ldconfig caches
#   * enabling/disabling systemd units
#   * baking the live "live" user's home directory
#   * trimming unused files to keep the squashfs small
#
# It runs after packages have been installed but before the squashfs is built.

set -e -u

# --- locale ------------------------------------------------------------------
sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
sed -i 's/#en_GB.UTF-8/en_GB.UTF-8/' /etc/locale.gen
sed -i 's/#ar_SA.UTF-8/ar_SA.UTF-8/' /etc/locale.gen
sed -i 's/#ar_EG.UTF-8/ar_EG.UTF-8/' /etc/locale.gen
locale-gen

# --- live user home ----------------------------------------------------------
if ! id -u live >/dev/null 2>&1; then
    useradd -m -G wheel,audio,video,storage,optical,network,disk,scanner,lp,adm,log,sys -s /usr/bin/zsh live
fi

# Ensure a passwordless live user (live-only convenience).
passwd -d live || true
passwd -d root || true

# Copy /etc/skel into the live user home if it isn't already there.
if [ -d /etc/skel ]; then
    cp -aT /etc/skel /home/live
    chown -R live:live /home/live
fi

# --- service units -----------------------------------------------------------
systemctl enable NetworkManager.service
systemctl enable ModemManager.service
systemctl enable systemd-resolved.service
systemctl enable bluetooth.service
systemctl enable cups.socket
systemctl enable systemd-zram-setup@zram0.service
systemctl enable systemd-oomd.service
systemctl enable earlyoom.service
systemctl enable sddm.service
systemctl enable fstrim.timer
systemctl enable systemd-timesyncd.service
systemctl enable aite-firstboot.service

# Disable noisy / heavy units that aren't useful in a live RAM session.
systemctl disable systemd-networkd.service || true
systemctl disable systemd-networkd.socket || true
systemctl mask man-db.timer || true
systemctl mask logrotate.timer || true
systemctl mask shadow.timer || true
systemctl mask systemd-readahead-collect.service || true
systemctl mask systemd-readahead-replay.service || true

# --- icon & theme caches -----------------------------------------------------
for d in /usr/share/icons/*; do
    if [ -d "$d" ]; then
        gtk-update-icon-cache -q -t -f "$d" 2>/dev/null || true
    fi
done
update-mime-database /usr/share/mime 2>/dev/null || true
update-desktop-database -q 2>/dev/null || true
fc-cache -fr 2>/dev/null || true

# --- shrink the squashfs -----------------------------------------------------
# Remove things that bloat the live image but aren't needed during a live
# session. Anything removed here can still be reinstalled via pacman after
# the user installs to disk.

# Locales other than en_*, ar_* — saves ~120 MB.
find /usr/share/locale -mindepth 1 -maxdepth 1 -type d \
    ! -name 'en*' ! -name 'ar*' ! -name 'C' ! -name 'POSIX' \
    -exec rm -rf {} + 2>/dev/null || true

# Man pages — keep the binaries usable but drop man pages from the live image.
rm -rf /usr/share/man/?? /usr/share/man/??.* /usr/share/man/??_* 2>/dev/null || true

# Pacman caches.
rm -rf /var/cache/pacman/pkg/* /var/lib/pacman/sync/* 2>/dev/null || true

# Doc trees that aren't useful on a live disk.
rm -rf /usr/share/doc/* /usr/share/gtk-doc /usr/share/info 2>/dev/null || true

# Static libraries inside packages — they were only needed at compile time.
find /usr -name '*.a' -delete 2>/dev/null || true

# --- branding ----------------------------------------------------------------
ln -sf /usr/share/aite-branding/aite.png /usr/share/pixmaps/aite-os.png 2>/dev/null || true

exit 0
