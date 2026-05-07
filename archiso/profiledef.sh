#!/usr/bin/env bash
# shellcheck disable=SC2034
#
# Aite OS — archiso profile definition
# Builds a live ISO that boots a Plasma 6 (Wayland) desktop fully into RAM.
# Tuned to be usable on machines with as little as 2 GB of RAM.

iso_name="aite-os"
iso_label="AITE_OS_$(date +%Y%m)"
iso_publisher="Aite OS <https://github.com/a78009866/Aite-os>"
iso_application="Aite OS Live"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=(
    'bios.syslinux.mbr'
    'bios.syslinux.eltorito'
    'uefi-x64.grub.esp'
    'uefi-x64.grub.eltorito'
)
arch="x86_64"
pacman_conf="pacman.conf"
# zstd at level 22 with long-range matching gives a much smaller squashfs (~20% smaller)
# than the archiso default. Slower to build, but the final download is smaller and
# decompression is fast on weak hardware.
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '22' '-b' '1M' '-Xbcj' 'x86')
bootstrap_tarball_compression=(zstd -c -T0 --long --auto-threads=logical -19 -)
file_permissions=(
    ["/etc/shadow"]="0:0:400"
    ["/etc/gshadow"]="0:0:400"
    ["/root"]="0:0:750"
    ["/root/.automated_script.sh"]="0:0:755"
    ["/root/.gnupg"]="0:0:700"
    ["/usr/local/bin/aite-firstboot"]="0:0:755"
    ["/usr/local/bin/aite-welcome"]="0:0:755"
    ["/etc/sudoers.d/g_wheel"]="0:0:440"
    ["/etc/polkit-1/rules.d/49-nopasswd_global.rules"]="0:0:644"
)
