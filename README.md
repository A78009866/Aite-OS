<div dir="rtl" lang="ar">

# Aite OS

نظام تشغيل **حي (Live)** خفيف، يعمل بكامله من الذاكرة (RAM)، مبني على Arch Linux مع واجهة **KDE Plasma 6 (Wayland)**. الهدف: تجربة سلسة وأنيقة حتى على أجهزة بـ **2 جيجابايت** من الذاكرة فقط.

| | |
|---|---|
| **القاعدة** | Arch Linux (rolling) |
| **النواة** | `linux-zen` |
| **الواجهة** | KDE Plasma 6 على Wayland |
| **مدير الدخول** | SDDM مع تسجيل دخول تلقائي للمستخدم `live` |
| **الأيقونات** | Tela-circle (زجاجي/Infinity) — مثبتة من AUR في الصورة الحية |
| **الذاكرة** | zram-generator + systemd-oomd + earlyoom + swappiness=180 |
| **افتراضياً** | يقلع مباشرة بـ `copytoram` ليعمل من الذاكرة بعد الإقلاع |
| **حجم ISO المتوقع** | ~1.4 – 1.7 جيجا |

</div>

---

## English

Aite OS is an ultra-light **live distribution** that copies itself fully into RAM at boot, then runs from there. It's built from `archiso` and ships **KDE Plasma 6 on Wayland**, tuned to feel comfortable on machines with as little as **2 GB of RAM** by combining `zram-generator`, `systemd-oomd`, `earlyoom`, and an aggressive `vm.swappiness=180`.

The default user is `live` (passwordless sudo, autologin via SDDM). Root is also passwordless inside the live session — this is intentional for a live system; if you install to disk via Calamares, set real passwords first.

---

## Repository layout

```
.
├── archiso/                    archiso profile (the actual ISO recipe)
│   ├── profiledef.sh           ISO metadata + boot modes + compression
│   ├── packages.x86_64         every package that ends up in the squashfs
│   ├── pacman.conf             pacman config used at BUILD time
│   ├── grub/                   GRUB EFI menu
│   ├── syslinux/               SYSLINUX BIOS menu
│   ├── efiboot/                systemd-boot loader entries
│   └── airootfs/               filesystem overlay (becomes / on the live ISO)
│       ├── etc/skel/           default Plasma + Konsole + Dolphin config
│       ├── etc/sddm.conf.d/    autologin
│       ├── etc/systemd/        zram, journald, system limits
│       ├── etc/sysctl.d/       low-RAM tuning
│       ├── etc/polkit-1/       passwordless wheel
│       ├── etc/sudoers.d/      passwordless wheel
│       ├── root/customize_airootfs.sh    chroot post-install hook
│       └── usr/local/bin/      aite-firstboot, aite-welcome
├── .github/workflows/build-iso.yml       CI that produces the ISO
└── README.md
```

---

## How to get the ISO

### 1. Download a pre-built ISO (easiest)

Each tagged release attaches the freshly-built ISO to the GitHub release page:

> **<https://github.com/a78009866/Aite-os/releases/latest>**

Verify the download:

```bash
sha256sum -c aite-os-*.iso.sha256
```

### 2. Trigger a build yourself in CI

The repo's GitHub Actions workflow builds the ISO inside an `archlinux:latest` container on every push to `main`, every PR, and every tag matching `v*`. You can also run it on demand:

> Repo → Actions → **Build Aite OS ISO** → Run workflow

The resulting ISO is uploaded as a workflow artifact named `aite-os-iso` and can be downloaded from the run page. Tagged builds (`git tag v0.1.0 && git push --tags`) also publish a public GitHub release.

### 3. Build it on your own machine

You need an Arch Linux box (or container) with `archiso` installed and root permissions:

```bash
sudo pacman -S --needed archiso
git clone https://github.com/a78009866/Aite-os.git
cd Aite-os
sudo mkarchiso -v -w /tmp/aite-work -o ./out archiso
ls -lh ./out
```

> The build needs ~10 GB of free disk and takes 15–30 minutes the first time, depending on mirror speed.

---

## Boot the ISO

### Write to a USB stick

```bash
sudo dd if=aite-os-*.iso of=/dev/sdX bs=4M status=progress oflag=direct,sync
sync
```

> Replace `/dev/sdX` with the actual block device of your stick — **double-check this**, `dd` will silently overwrite anything you point it at.

### Try it in QEMU first

```bash
qemu-system-x86_64 -enable-kvm -m 2048 -smp 2 \
    -bios /usr/share/edk2-ovmf/x64/OVMF.fd \
    -cdrom aite-os-*.iso
```

The default GRUB / SYSLINUX entry uses `copytoram`, so once the desktop appears the ISO/USB can be safely unplugged.

---

## Tuning notes

* **Boot copies the system into RAM** via the `copytoram` archiso kernel parameter. On a 2 GB machine this leaves enough headroom for Plasma + Firefox; on 1 GB choose the *"run from disk"* boot entry instead.
* **zram swap** is enabled by default at half of RAM, capped at 2 GB, with `zstd` compression. Combined with `vm.swappiness=180` this lets the kernel transparently compress cold pages so the desktop doesn't swap-thrash.
* **systemd-oomd** + **earlyoom** are both enabled — between them they kill runaway processes long before the kernel OOM killer kicks in.
* **Journald is `volatile`** with a 32 MB cap, so logs never grow unbounded in a live session.
* **No baseline encryption / no auto-update / no telemetry**. This is a live OS for testing, recovery, and demos.

---

## Credits

Aite OS is a thin profile on top of [archiso](https://wiki.archlinux.org/title/Archiso). The desktop is [KDE Plasma 6](https://kde.org/plasma-desktop/), the icons are based on the excellent [Tela Circle](https://github.com/vinceliuice/Tela-circle-icon-theme) icon theme by Vince Liuice. Calamares is included for users who want to install Aite OS to disk.

License: MIT for the profile in this repo. Each bundled package keeps its own upstream license.
