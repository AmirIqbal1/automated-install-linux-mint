#!/bin/bash
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "Run with: sudo ./install-mint.sh"
  exit 1
fi

echo "Linux Mint setup script - Mint 22.x / Ubuntu 24.04 base"
sleep 3

CURRENT_USER="${SUDO_USER:-$(logname)}"

apt-get update
apt-get upgrade -y

echo "Installing core packages..."
apt-get install -y \
  curl wget zip unzip gdebi apt-transport-https software-properties-common \
  ca-certificates gnupg lsb-release gufw git gparted extrepo htop mat2 openvpn \
  rkhunter synaptic tilix flatpak util-linux preload zram-tools \
  libreoffice bleachbit deluge foliate gimp thunderbird plank tlp \
  celluloid timeshift mint-meta-codecs vlc

echo "Setting up Flathub..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo "Swap check:"
swapon --show || true

echo "Applying sysctl tweak..."
cat >/etc/sysctl.d/99-mint-performance.conf <<EOF
vm.vfs_cache_pressure=50
EOF
sysctl --system

apt-get --fix-broken install -y

echo "Installing Brave browser..."
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
apt update && apt install brave-browser -y

echo "Installing VeraCrypt Ubuntu 24.04 package..."
wget -q https://launchpad.net/veracrypt/trunk/1.26.24/+download/veracrypt-1.26.24-Ubuntu-24.04-amd64.deb -O veracrypt.deb
apt-get install -y ./veracrypt.deb
rm veracrypt.deb

echo "Installing balenaEtcher..."
wget -q https://github.com/balena-io/etcher/releases/download/v2.1.6/balena-etcher_2.1.6_amd64.deb
apt-get install -y ./balena-etcher_2.1.6_amd64.deb
rm balena-etcher_2.1.6_amd64.deb

echo "Installing VS Code..."
install -d -m 0755 /etc/apt/keyrings
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/keyrings/vscode.gpg
echo "deb [signed-by=/etc/apt/keyrings/vscode.gpg] https://packages.microsoft.com/repos/code stable main" \
  >/etc/apt/sources.list.d/vscode.list
apt-get update
apt-get install -y code

echo "Installing Spotify..."
curl -fsSL https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.asc \
  | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb https://repository.spotify.com stable non-free" \
  >/etc/apt/sources.list.d/spotify.list
apt-get update
apt-get install -y spotify-client

echo "Installing Librewolf Browser"
apt update && sudo apt install extrepo -y
extrepo enable librewolf && sudo extrepo update librewolf
apt update && sudo apt install librewolf -y

echo "Installing AppFlowy"
wget -q https://github.com/AppFlowy-IO/AppFlowy/releases/download/0.12.1/AppFlowy-0.12.1-linux-x86_64.deb 
apt-get install -y AppFlowy-0.12.1-linux-x86_64.deb
rm AppFlowy-0.12.1-linux-x86_64.deb

echo "Removing Deja Dup & Celluloid if installed..."
apt-get remove --purge -y deja-dup celluloid || true

echo "Installing Flatpak apps..."
flatpak install -y flathub \
  com.stremio.Stremio \
  org.telegram.desktop \
  io.github.hvdwofl.jExifToolGUI \
  com.github.unrud.VideoDownloader \
  io.github.flattool.Warehouse

echo "Downloading scripts..."
wget -q https://raw.githubusercontent.com/AmirIqbal1/rkhunter-script/master/rkhunter-check.sh
wget -q https://raw.githubusercontent.com/AmirIqbal1/Flatpak-cleaner/refs/heads/main/flatpak_cleanup.sh
chmod +x rkhunter-check.sh flatpak_cleanup.sh

echo "Installing coloured terminal prompts..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$SCRIPT_DIR/setup-terminal-prompts.sh" ]; then
    bash "$SCRIPT_DIR/setup-terminal-prompts.sh"
else
    echo "Warning: setup-terminal-prompts.sh not found. Skipping terminal prompt setup."
fi

echo "Cloning hardening-mint tools..."
git clone -q https://github.com/AmirIqbal1/hardening-linux-mint.git || true

echo "Enabling SSD TRIM..."
fstrim -av || true
systemctl enable --now fstrim.timer

echo "Enabling TLP..."
systemctl enable --now tlp || true

echo "Cleaning up..."
apt-get autoremove -y
apt-get clean
apt-get autoclean

echo -e "\e[42mDone. Reboot recommended.\e[0m"
