# 🍃 install-mint.sh — Linux Mint Auto Setup Script

![Linux Mint](https://img.shields.io/badge/Linux%20Mint-22.x-86BE43?logo=linuxmint)
![Ubuntu Base](https://img.shields.io/badge/Ubuntu-24.04-E95420?logo=ubuntu)
![Shell Script](https://img.shields.io/badge/script-bash-1f425f.svg)
![Maintained](https://img.shields.io/badge/maintained-yes-brightgreen)

A bash script that automates the installation of essential desktop applications, developer tools, system utilities, and performance tweaks for **Linux Mint 22.x** (Ubuntu 24.04 base).

---

# 🚀 TL;DR

This script:

- Installs popular desktop apps using APT, Flatpak, and official `.deb` packages
- Adds SSD and memory optimisations
- Enables swap compression with `zram`
- Installs TLP for improved battery life on laptops
- Enables SSD TRIM automatically
- Downloads maintenance and security helper scripts
- Uses Flatpak only where it makes sense

---

# 📦 How to Use

Run the following commands:

```bash
chmod +x install-mint.sh
sudo ./install-mint.sh
```

---

# 🖥️ APT Installed Applications

```text
curl
brave
wget
zip / unzip
gdebi
git
htop
gparted
gufw
synaptic
tilix
openvpn
rkhunter
preload
zram-tools
flatpak
libreoffice
librewolf
bleachbit
deluge
foliate
gimp
thunderbird
plank
tlp
timeshift
mint-meta-codecs
vlc
```

---

# 📥 Installed via Official .deb Packages

| Application      | Install Method |
|------------------|----------------|
| VeraCrypt        | Ubuntu 24.04 `.deb` |
| Balena Etcher    | Official `.deb` |

---

# 🧠 Installed via Official Repositories

| Application       | Source |
|-------------------|--------|
| VS Code           | Microsoft APT Repository |
| Spotify           | Spotify APT Repository |

---

# 📦 Flatpak Applications

```text
Stremio
Telegram
Warehouse
Video Downloader
jExifToolGUI
```

---

# ⚡ System Enhancements

## SSD TRIM Support

Executes:

```bash
fstrim -av
```

Enables:

```bash
fstrim.timer
```

Automatically trims SSDs weekly.

---

## 🔋 TLP Power Optimisation

TLP is installed and enabled automatically.

Helps reduce battery drain on laptops and improves power efficiency.

---

# 🧠 Memory & Cache Tweaks

## zram Compression

Installs:

```bash
zram-tools
```

Compresses swap data in RAM for better responsiveness under memory pressure.

---

## Filesystem Cache Optimisation

Applies:

```bash
vm.vfs_cache_pressure=50
```

Helps Linux keep useful filesystem metadata cached longer.

Persisted in:

```text
/etc/sysctl.d/99-mint-performance.conf
```

---

# 🛠️ Additional Scripts & Repositories

| Tool/Repo                                                             | Description |
|------------------------------------------------------------------------|-------------|
| [`rkhunter-check`](https://github.com/AmirIqbal1/rkhunter-script)     | Automates rkhunter scans |
| [`flatpak_cleanup.sh`](https://github.com/AmirIqbal1/Flatpak-cleaner) | Removes unused Flatpak data |
| [`hardening-debian`](https://github.com/AmirIqbal1/hardening-debian)  | Security hardening tools |

---

# 🛡️ Rootkit Hunter (rkhunter)

`rkhunter` is installed to help detect:

- Rootkits
- Backdoors
- Suspicious binaries
- Local exploits

Helpful guide:

[How to configure rkhunter]([https://tecadmin.net/how-to-install-rkhunter-on-ubuntu](https://linux.how2shout.com/install-and-use-rootkit-hunter-on-ubuntu-such-as-24-04-or-22-04/))

---

# 📋 Tested On

- Linux Mint 22.x Cinnamon
- Ubuntu 24.04 base

---

# 🔄 After Installation

A reboot is recommended after installation completes.

```bash
sudo reboot
```

---

# ⚠️ Notes

- Review scripts before running on production systems
- Some package versions may change upstream over time
- Internet connection required
- Run at your own risk
