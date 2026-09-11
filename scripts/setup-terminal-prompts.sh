#!/usr/bin/env bash
set -Eeuo pipefail

if (( EUID != 0 )); then
    echo "Run this helper with sudo, or let install-mint.sh call it."
    exit 1
fi

TARGET_USER="${1:-${SUDO_USER:-}}"

if [[ -z "$TARGET_USER" || "$TARGET_USER" == "root" ]]; then
    echo "Could not determine the normal desktop user."
    exit 1
fi

TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
TARGET_GROUP="$(id -gn "$TARGET_USER")"

if [[ -z "$TARGET_HOME" || ! -d "$TARGET_HOME" ]]; then
    echo "Could not determine the home directory for $TARGET_USER."
    exit 1
fi

USER_BASHRC="$TARGET_HOME/.bashrc"
ROOT_BASHRC="/root/.bashrc"

remove_managed_block() {
    local file="$1"

    touch "$file"

    sed -i \
        '/# AMIR_CUSTOM_PROMPT_START/,/# AMIR_CUSTOM_PROMPT_END/d' \
        "$file"
}

remove_managed_block "$USER_BASHRC"
remove_managed_block "$ROOT_BASHRC"

cat >> "$USER_BASHRC" <<'USER_PROMPT'

# AMIR_CUSTOM_PROMPT_START
# Managed by automated-install-linux-mint
case "$TERM" in
    xterm*|rxvt*|screen*|tmux*|linux*)
        PS1='\[\e[1;32m\][USER]\[\e[0m\] \[\e[1;36m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '
        ;;
esac
# AMIR_CUSTOM_PROMPT_END
USER_PROMPT

cat >> "$ROOT_BASHRC" <<'ROOT_PROMPT'

# AMIR_CUSTOM_PROMPT_START
# Managed by automated-install-linux-mint
case "$TERM" in
    xterm*|rxvt*|screen*|tmux*|linux*)
        PS1='\[\e[1;31m\][ROOT]\[\e[0m\] \[\e[1;33m\]\u@\h\[\e[0m\]:\[\e[1;36m\]\w\[\e[0m\]# '
        ;;
esac
# AMIR_CUSTOM_PROMPT_END
ROOT_PROMPT

chown "$TARGET_USER:$TARGET_GROUP" "$USER_BASHRC"

chmod 0644 \
    "$USER_BASHRC" \
    "$ROOT_BASHRC"

echo "Coloured Bash prompts configured for $TARGET_USER and root."
