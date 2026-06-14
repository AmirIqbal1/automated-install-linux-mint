#!/usr/bin/env bash
set -e

echo "Setting up coloured Bash prompts..."

USER_HOME="/home/${SUDO_USER:-$USER}"

USER_BASHRC="$USER_HOME/.bashrc"
ROOT_BASHRC="/root/.bashrc"

USER_PROMPT="PS1='\\[\\e[1;32m\\][USER]\\[\\e[0m\\] \\[\\e[1;36m\\]\\u@\\h\\[\\e[0m\\]:\\[\\e[1;34m\\]\\w\\[\\e[0m\\]\\$ '"
ROOT_PROMPT="PS1='\\[\\e[1;31m\\][ROOT]\\[\\e[0m\\] \\[\\e[1;33m\\]\\u@\\h\\[\\e[0m\\]:\\[\\e[1;36m\\]\\w\\[\\e[0m\\]# '"

add_prompt() {
    local file="$1"
    local prompt="$2"

    touch "$file"

    if ! grep -q "AMIR_CUSTOM_PROMPT_START" "$file"; then
        cat >> "$file" <<EOF

# AMIR_CUSTOM_PROMPT_START
# Clear coloured prompt for Linux Mint / Tilix
case "\$TERM" in
    xterm*|rxvt*|screen*|tmux*|linux*)
        $prompt
        ;;
esac
# AMIR_CUSTOM_PROMPT_END
EOF
    else
        echo "Prompt already exists in $file"
    fi
}

add_prompt "$USER_BASHRC" "$USER_PROMPT"
add_prompt "$ROOT_BASHRC" "$ROOT_PROMPT"

chown "${SUDO_USER:-$USER}:${SUDO_USER:-$USER}" "$USER_BASHRC"

echo "Done. Open a new Tilix tab or run: source ~/.bashrc"
