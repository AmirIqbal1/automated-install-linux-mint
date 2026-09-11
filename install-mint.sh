#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

readonly LOG_FILE="/var/log/mint-auto-setup.log"
readonly REQUIRED_MINT_MAJOR="22"
readonly REQUIRED_UBUNTU_CODENAME="noble"
readonly REQUIRED_ARCH="amd64"

# Pinned third-party application versions.
# Update these periodically after checking the upstream releases.
readonly VERACRYPT_VERSION="1.26.29"
readonly ETCHER_VERSION="2.1.6"
readonly APPFLOWY_VERSION="0.14.1"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TEMP_DIR=""
TARGET_USER=""
TARGET_GROUP=""
TARGET_HOME=""
TOOLS_DIR=""

log() {
    printf '\n\033[1;32m==> %s\033[0m\n' "$*"
}

warn() {
    printf '\033[1;33mWARNING: %s\033[0m\n' "$*" >&2
}

fail() {
    printf '\033[1;31mERROR: %s\033[0m\n' "$*" >&2
    exit 1
}

cleanup() {
    if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
        rm -rf -- "$TEMP_DIR"
    fi
}

on_error() {
    local exit_code=$?
    local line_no="${1:-unknown}"
    local command="${2:-unknown}"

    printf '\n\033[1;31mSetup failed on line %s.\033[0m\n' "$line_no" >&2
    printf 'Command: %s\n' "$command" >&2
    printf 'Log: %s\n' "$LOG_FILE" >&2

    exit "$exit_code"
}

trap 'on_error "$LINENO" "$BASH_COMMAND"' ERR
trap cleanup EXIT

# ---------------------------------------------------------------------------
# Root / user checks
# ---------------------------------------------------------------------------

if (( EUID != 0 )); then
    fail "Run this installer from your normal account with: sudo ./install-mint.sh"
fi

if [[ -z "${SUDO_USER:-}" || "${SUDO_USER}" == "root" ]]; then
    fail "Do not log in as root to run this script. Sign in normally, then use sudo ./install-mint.sh"
fi

TARGET_USER="$SUDO_USER"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"

[[ -n "$TARGET_HOME" && -d "$TARGET_HOME" ]] \
    || fail "Could not determine the home directory for $TARGET_USER."

TARGET_GROUP="$(id -gn "$TARGET_USER")"
TOOLS_DIR="$TARGET_HOME/Tools/linux-mint"

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------

install -d -m 0755 "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

exec > >(tee -a "$LOG_FILE") 2>&1

# ---------------------------------------------------------------------------
# Compatibility checks
# ---------------------------------------------------------------------------

log "Checking system compatibility"

[[ -r /etc/os-release ]] || fail "/etc/os-release could not be read."

# shellcheck disable=SC1091
source /etc/os-release

[[ "${ID:-}" == "linuxmint" ]] \
    || fail "This installer supports Linux Mint only. Detected: ${PRETTY_NAME:-unknown}."

[[ "${VERSION_ID:-}" == "${REQUIRED_MINT_MAJOR}"* ]] \
    || fail "Linux Mint ${REQUIRED_MINT_MAJOR}.x is required. Detected: ${VERSION_ID:-unknown}."

[[ "${UBUNTU_CODENAME:-}" == "$REQUIRED_UBUNTU_CODENAME" ]] \
    || fail "Ubuntu 24.04/noble base is required. Detected codename: ${UBUNTU_CODENAME:-unknown}."

ARCH="$(dpkg --print-architecture)"

[[ "$ARCH" == "$REQUIRED_ARCH" ]] \
    || fail "This installer currently supports amd64 only. Detected: $ARCH."

printf 'Detected: %s\n' "${PRETTY_NAME:-Linux Mint}"
printf 'Architecture: %s\n' "$ARCH"
printf 'Target user: %s\n' "$TARGET_USER"
printf 'Log file: %s\n' "$LOG_FILE"

# ---------------------------------------------------------------------------
# Temporary workspace / APT helpers
# ---------------------------------------------------------------------------

TEMP_DIR="$(mktemp -d -t mint-auto-setup.XXXXXX)"

export DEBIAN_FRONTEND=noninteractive

APT_GET=(
    apt-get
    -o DPkg::Lock::Timeout=120
)

apt_update() {
    "${APT_GET[@]}" update
}

apt_install() {
    "${APT_GET[@]}" install -y "$@"
}

install_deb() {
    local name="$1"
    local url="$2"
    local filename="$3"
    local destination="$TEMP_DIR/$filename"

    log "Installing $name"

    curl \
        --fail \
        --location \
        --silent \
        --show-error \
        --retry 3 \
        --retry-delay 2 \
        --output "$destination" \
        "$url"

    apt_install "$destination"
}

# ---------------------------------------------------------------------------
# Update Linux Mint
# ---------------------------------------------------------------------------

log "Updating Linux Mint"

apt_update
"${APT_GET[@]}" upgrade -y

# ---------------------------------------------------------------------------
# Core packages
# ---------------------------------------------------------------------------

log "Installing core applications and utilities"

apt_install \
    ca-certificates \
    curl \
    wget \
    zip \
    unzip \
    gdebi \
    software-properties-common \
    gnupg \
    lsb-release \
    gufw \
    git \
    gparted \
    extrepo \
    htop \
    mat2 \
    openvpn \
    rkhunter \
    synaptic \
    tilix \
    flatpak \
    util-linux \
    preload \
    zram-tools \
    libreoffice \
    bleachbit \
    deluge \
    foliate \
    gimp \
    plank \
    timeshift \
    mint-meta-codecs \
    vlc

# ---------------------------------------------------------------------------
# Remove unwanted default applications
# ---------------------------------------------------------------------------

log "Removing unwanted default applications"

"${APT_GET[@]}" remove --purge -y \
    deja-dup \
    celluloid \
    || warn "Deja Dup or Celluloid could not be removed; continuing."

# ---------------------------------------------------------------------------
# Flathub
# ---------------------------------------------------------------------------

log "Configuring Flathub"

flatpak remote-add \
    --system \
    --if-not-exists \
    flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo

# ---------------------------------------------------------------------------
# Performance settings
# ---------------------------------------------------------------------------

log "Applying filesystem cache setting"

cat > /etc/sysctl.d/99-mint-performance.conf <<'SYSCTL'
# Managed by automated-install-linux-mint
vm.vfs_cache_pressure=50
SYSCTL

sysctl --system

# ---------------------------------------------------------------------------
# Brave Browser
# ---------------------------------------------------------------------------

log "Installing Brave Browser"

curl -fsSLo \
    /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

curl -fsSLo \
    /etc/apt/sources.list.d/brave-browser-release.sources \
    https://brave-browser-apt-release.s3.brave.com/brave-browser.sources

apt_update
apt_install brave-browser

# ---------------------------------------------------------------------------
# Visual Studio Code
# ---------------------------------------------------------------------------

log "Installing Visual Studio Code"

install -d -m 0755 /usr/share/keyrings

wget -qO- \
    https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor --yes -o /usr/share/keyrings/microsoft.gpg

chmod 0644 /usr/share/keyrings/microsoft.gpg

cat > /etc/apt/sources.list.d/vscode.sources <<'VSCODE'
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/microsoft.gpg
VSCODE

apt_update
apt_install code

# ---------------------------------------------------------------------------
# Spotify
# ---------------------------------------------------------------------------

log "Installing Spotify"

curl -fsSL \
    https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.asc \
    | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg

chmod 0644 /etc/apt/trusted.gpg.d/spotify.gpg

cat > /etc/apt/sources.list.d/spotify.list <<'SPOTIFY'
deb https://repository.spotify.com stable non-free
SPOTIFY

apt_update
apt_install spotify-client

# ---------------------------------------------------------------------------
# LibreWolf
# ---------------------------------------------------------------------------

log "Installing LibreWolf"

extrepo enable librewolf

apt_update
apt_install librewolf

# ---------------------------------------------------------------------------
# Official .deb packages
# ---------------------------------------------------------------------------

install_deb \
    "VeraCrypt ${VERACRYPT_VERSION}" \
    "https://github.com/veracrypt/VeraCrypt/releases/download/VeraCrypt_${VERACRYPT_VERSION}/veracrypt-${VERACRYPT_VERSION}-Ubuntu-24.04-amd64.deb" \
    "veracrypt-${VERACRYPT_VERSION}-Ubuntu-24.04-amd64.deb"

install_deb \
    "balenaEtcher ${ETCHER_VERSION}" \
    "https://github.com/balena-io/etcher/releases/download/v${ETCHER_VERSION}/balena-etcher_${ETCHER_VERSION}_amd64.deb" \
    "balena-etcher_${ETCHER_VERSION}_amd64.deb"

install_deb \
    "AppFlowy ${APPFLOWY_VERSION}" \
    "https://github.com/AppFlowy-IO/AppFlowy/releases/download/${APPFLOWY_VERSION}/AppFlowy-${APPFLOWY_VERSION}-linux-x86_64.deb" \
    "AppFlowy-${APPFLOWY_VERSION}-linux-x86_64.deb"

# ---------------------------------------------------------------------------
# Flatpak applications
# ---------------------------------------------------------------------------

log "Installing Flatpak applications"

FLATPAK_APPS=(
    org.jellyfin.JellyfinDesktop
    com.stremio.Stremio
    io.github.mfat.sshpilot
    org.telegram.desktop
    io.github.hvdwofl.jExifToolGUI
    com.github.unrud.VideoDownloader
    io.github.flattool.Warehouse
)

for app in "${FLATPAK_APPS[@]}"; do
    if flatpak info --system "$app" >/dev/null 2>&1; then
        printf 'Already installed: %s\n' "$app"
    else
        flatpak install --system -y flathub "$app"
    fi
done

# ---------------------------------------------------------------------------
# Personal helper tools
# ---------------------------------------------------------------------------

log "Installing personal helper tools"

install -d \
    -m 0755 \
    -o "$TARGET_USER" \
    -g "$TARGET_GROUP" \
    "$TARGET_HOME/Tools"

install -d \
    -m 0755 \
    -o "$TARGET_USER" \
    -g "$TARGET_GROUP" \
    "$TOOLS_DIR"

curl \
    --fail \
    --location \
    --silent \
    --show-error \
    --retry 3 \
    -o "$TOOLS_DIR/rkhunter-check.sh" \
    https://raw.githubusercontent.com/AmirIqbal1/rkhunter-script/master/rkhunter-check.sh

curl \
    --fail \
    --location \
    --silent \
    --show-error \
    --retry 3 \
    -o "$TOOLS_DIR/flatpak_cleanup.sh" \
    https://raw.githubusercontent.com/AmirIqbal1/Flatpak-cleaner/main/flatpak_cleanup.sh

chmod 0755 \
    "$TOOLS_DIR/rkhunter-check.sh" \
    "$TOOLS_DIR/flatpak_cleanup.sh"

chown \
    "$TARGET_USER:$TARGET_GROUP" \
    "$TOOLS_DIR/rkhunter-check.sh" \
    "$TOOLS_DIR/flatpak_cleanup.sh"

# ---------------------------------------------------------------------------
# Hardening repository
# ---------------------------------------------------------------------------

HARDENING_DIR="$TOOLS_DIR/hardening-linux-mint"

if [[ -d "$HARDENING_DIR/.git" ]]; then

    log "Updating hardening-linux-mint"

    runuser -u "$TARGET_USER" -- \
        git -C "$HARDENING_DIR" pull --ff-only

elif [[ -e "$HARDENING_DIR" ]]; then

    warn "$HARDENING_DIR already exists but is not a Git repository. Leaving it untouched."

else

    log "Cloning hardening-linux-mint"

    runuser -u "$TARGET_USER" -- \
        git clone \
        https://github.com/AmirIqbal1/hardening-linux-mint.git \
        "$HARDENING_DIR"

fi

# ---------------------------------------------------------------------------
# Terminal prompts
# ---------------------------------------------------------------------------

log "Installing coloured Bash prompts"

PROMPT_SCRIPT="$SCRIPT_DIR/scripts/setup-terminal-prompts.sh"

if [[ -f "$PROMPT_SCRIPT" ]]; then
    bash "$PROMPT_SCRIPT" "$TARGET_USER"
else
    warn "$PROMPT_SCRIPT was not found. Terminal prompt setup was skipped."
fi

# ---------------------------------------------------------------------------
# zram
# ---------------------------------------------------------------------------

log "Enabling zram"

if systemctl cat zramswap.service >/dev/null 2>&1; then

    systemctl enable --now zramswap.service

else

    warn "zramswap.service was not found. zram-tools is installed, but the service could not be enabled automatically."

fi

# ---------------------------------------------------------------------------
# SSD TRIM
# ---------------------------------------------------------------------------

log "Enabling weekly SSD TRIM"

systemctl enable --now fstrim.timer

fstrim -av \
    || warn "Immediate TRIM was not supported on one or more filesystems. The weekly timer is still enabled."

# ---------------------------------------------------------------------------
# Swap information
# ---------------------------------------------------------------------------

log "Checking swap"

swapon --show || true

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------

log "Cleaning APT cache"

"${APT_GET[@]}" clean

# ---------------------------------------------------------------------------
# Finished
# ---------------------------------------------------------------------------

printf '\n\033[1;42m Linux Mint setup completed successfully. \033[0m\n'
printf 'Helper tools: %s\n' "$TOOLS_DIR"
printf 'Installation log: %s\n' "$LOG_FILE"
printf 'Reboot recommended: sudo reboot\n'
