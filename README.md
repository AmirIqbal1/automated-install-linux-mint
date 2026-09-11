# Linux Mint 22 Auto Setup

Automated post-install setup for **Linux Mint 22.x Cinnamon**, based on Ubuntu 24.04 LTS.

The installer handles system updates, desktop applications, developer tools, Flatpaks, browser repositories, performance settings, helper scripts and terminal configuration.

---

## Supported Systems

Currently supported:

- Linux Mint 22.x
- Ubuntu 24.04 / Noble base
- Cinnamon desktop
- AMD64 / x86_64 computers

The installer checks the operating system and architecture before making changes.

It will refuse to run on unsupported systems.

---

## Quick Install

On a fresh Linux Mint installation:

```bash
sudo apt update
sudo apt install -y git

git clone https://github.com/AmirIqbal1/automated-install-linux-mint.git
cd automated-install-linux-mint

chmod +x install-mint.sh
chmod +x scripts/setup-terminal-prompts.sh

sudo ./install-mint.sh
```

When installation finishes:

```bash
sudo reboot
```

---

# Repository Layout

```text
automated-install-linux-mint/
├── install-mint.sh
├── scripts/
│   └── setup-terminal-prompts.sh
├── README.md
└── LICENSE
```

### `install-mint.sh`

Main installer.

Handles:

- Linux Mint compatibility checks
- System updates
- APT applications
- Third-party repositories
- Flatpak applications
- Official `.deb` packages
- zram
- SSD TRIM
- filesystem cache configuration
- helper tools
- terminal setup
- logging

### `scripts/setup-terminal-prompts.sh`

Configures coloured Bash prompts for:

- the normal desktop user
- root shells

Normal user sessions show a green `[USER]` marker.

Root sessions show a red `[ROOT]` marker.

This makes it easier to identify privileged terminal sessions.

---

# Applications Installed

## APT Packages

The main Linux Mint / Ubuntu repositories are used for:

```text
BleachBit
Deluge
Foliate
GIMP
GParted
GUFW
LibreOffice
Plank
Synaptic
Tilix
Timeshift
VLC

curl
extrepo
Flatpak
gdebi
Git
GNUPG
htop
lsb-release
MAT2
OpenVPN
preload
rkhunter
software-properties-common
unzip
util-linux
wget
zip
zram-tools
```

Linux Mint multimedia codecs are also installed using:

```text
mint-meta-codecs
```

---

# Browsers

## Brave

Brave Browser is installed using Brave's official APT repository.

This means Brave can subsequently be updated normally through APT and Linux Mint's update system.

## LibreWolf

LibreWolf is installed using `extrepo`.

The LibreWolf repository is configured automatically before the browser is installed.

---

# Developer Tools

## Visual Studio Code

Visual Studio Code is installed using Microsoft's official Debian repository.

The Microsoft signing key and repository are configured automatically.

Future VS Code updates are then handled through APT.

---

# Spotify

Spotify is installed using Spotify's official Debian repository.

Its signing key and repository are configured before installing:

```text
spotify-client
```

---

# Official `.deb` Applications

Some applications are installed directly from official release packages.

Currently pinned versions:

| Application | Version |
|---|---:|
| VeraCrypt | 1.26.29 |
| balenaEtcher | 2.1.6 |
| AppFlowy | 0.14.1 |

The packages are downloaded into a temporary directory.

They are installed using APT and the temporary files are automatically deleted afterwards.

Versions are deliberately pinned so a known release is installed rather than having the script unexpectedly change when upstream releases are published.

These version numbers should be reviewed periodically.

---

# Flatpak Applications

Flathub is configured automatically.

The following applications are installed system-wide:

```text
Jellyfin Desktop
Stremio
SSH Pilot
Telegram
jExifToolGUI
Video Downloader
Warehouse
```

Flatpak IDs:

```text
org.jellyfin.JellyfinDesktop
com.stremio.Stremio
io.github.mfat.sshpilot
org.telegram.desktop
io.github.hvdwofl.jExifToolGUI
com.github.unrud.VideoDownloader
io.github.flattool.Warehouse
```

Already-installed Flatpaks are detected and skipped.

---

# Removed Applications

The installer removes:

```text
Deja Dup
Celluloid
```

VLC is used instead of Celluloid.

Timeshift remains installed for system snapshots.

---

# zram

The installer installs:

```text
zram-tools
```

If the `zramswap.service` systemd service is available, it is automatically enabled and started.

zram uses compressed RAM as swap and can improve responsiveness when the system is under memory pressure.

Check it after installation with:

```bash
swapon --show
```

---

# Filesystem Cache Setting

The installer creates:

```text
/etc/sysctl.d/99-mint-performance.conf
```

containing:

```text
vm.vfs_cache_pressure=50
```

The setting is loaded immediately using:

```bash
sysctl --system
```

---

# SSD TRIM

The installer enables the standard systemd TRIM timer:

```text
fstrim.timer
```

This allows supported SSDs to be trimmed automatically.

The installer also attempts an initial:

```bash
fstrim -av
```

A drive that does not support TRIM will not cause the whole installation to fail.

Check the timer with:

```bash
systemctl status fstrim.timer
```

---

# Power Management

TLP is deliberately **not installed**.

Linux Mint 22 already includes integrated power-profile management.

Keeping Mint's standard power management avoids running competing power-management systems on laptops.

---

# Personal Helper Tools

Additional personal tools are installed into:

```text
~/Tools/linux-mint/
```

After installation it should look similar to:

```text
~/Tools/linux-mint/
├── rkhunter-check.sh
├── flatpak_cleanup.sh
└── hardening-linux-mint/
```

### rkhunter helper

Downloaded from:

```text
AmirIqbal1/rkhunter-script
```

Installed as:

```text
~/Tools/linux-mint/rkhunter-check.sh
```

### Flatpak cleanup

Downloaded from:

```text
AmirIqbal1/Flatpak-cleaner
```

Installed as:

```text
~/Tools/linux-mint/flatpak_cleanup.sh
```

### Linux Mint hardening tools

The repository:

```text
AmirIqbal1/hardening-linux-mint
```

is cloned into:

```text
~/Tools/linux-mint/hardening-linux-mint/
```

If the repository already exists, the installer performs:

```bash
git pull --ff-only
```

instead of trying to clone another copy.

---

# Terminal Prompts

The installer configures Bash prompts for both the desktop user and root.

Example standard-user prompt:

```text
[USER] amir@mint:~/Documents$
```

Example root prompt:

```text
[ROOT] root@mint:/etc#
```

The user marker is green.

The root marker is red.

The prompt configuration is managed using markers inside `.bashrc`:

```text
# AMIR_CUSTOM_PROMPT_START
...
# AMIR_CUSTOM_PROMPT_END
```

Rerunning the installer replaces the existing managed block instead of creating duplicate prompts.

---

# Installation Log

Installation output is written to:

```text
/var/log/mint-auto-setup.log
```

If installation fails, the script prints:

- the failed line number
- the failed command
- the log location

View the complete log with:

```bash
less /var/log/mint-auto-setup.log
```

or:

```bash
tail -n 100 /var/log/mint-auto-setup.log
```

---

# Safe to Run Again

The installer is designed to be rerunnable.

For example:

- APT will skip already-installed current packages.
- Flathub is only added if it does not already exist.
- Installed Flatpaks are detected.
- repository configuration files are replaced rather than duplicated.
- helper scripts are overwritten with their latest repository copies.
- the hardening repository is updated rather than cloned twice.
- terminal prompt blocks are replaced instead of duplicated.
- temporary `.deb` files are deleted after each run.

This also means that if installation stops because of an internet or upstream repository problem, the installer can normally just be run again:

```bash
sudo ./install-mint.sh
```

---

# Temporary Files

Third-party `.deb` packages are downloaded into a temporary directory under:

```text
/tmp/
```

The temporary directory is removed automatically whether the script succeeds or fails.

Third-party installers are therefore no longer left in the Git repository or current working directory.

---

# Architecture Check

Some applications installed by this script use AMD64-specific packages.

The installer therefore checks:

```bash
dpkg --print-architecture
```

and currently requires:

```text
amd64
```

ARM support can be added later by defining separate ARM package URLs.

---

# Updating Pinned Applications

Application versions are defined near the top of `install-mint.sh`:

```bash
readonly VERACRYPT_VERSION="1.26.29"
readonly ETCHER_VERSION="2.1.6"
readonly APPFLOWY_VERSION="0.14.1"
```

When updating one of these, also check that the corresponding download URL still follows the same upstream naming convention.

Do not blindly change version numbers without checking the official release.

---

# Testing Changes

Before committing changes to either shell script, run:

```bash
bash -n install-mint.sh
bash -n scripts/setup-terminal-prompts.sh
```

If ShellCheck is installed, also run:

```bash
shellcheck install-mint.sh
shellcheck scripts/setup-terminal-prompts.sh
```

The best final test is a clean Linux Mint 22.x virtual machine.

---

# Recommended Fresh-Install Test

After installing Linux Mint in a VM:

```bash
sudo apt update
sudo apt install -y git

git clone https://github.com/AmirIqbal1/automated-install-linux-mint.git
cd automated-install-linux-mint

chmod +x install-mint.sh
chmod +x scripts/setup-terminal-prompts.sh

sudo ./install-mint.sh
```

After completion:

```bash
sudo reboot
```

Then check:

```bash
swapon --show
systemctl status fstrim.timer
flatpak list
code --version
git --version
```

Also manually confirm that the expected desktop applications open correctly.

Finally, run the installer **a second time**.

A successful second run is an important test because the installer is intended to be idempotent.

---

# Notes

- Internet access is required.
- Run the installer from a normal desktop account using `sudo`.
- Do not run it from a direct root login.
- Linux Mint 22.x AMD64 is currently required.
- Third-party package versions may need updating over time.
- Review scripts before running them on important systems.
- A reboot is recommended after installation.

---

# License

See `LICENSE`.
