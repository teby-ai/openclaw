#!/bin/sh
# Restore persistent symlinks before starting OpenClaw.
# SSH keys are stored in ~/.openclaw/ssh/ (inside the persistent volume)
# and symlinked to ~/.ssh so git/ssh find them automatically.

HOME_DIR="${HOME:-/root}"
OPENCLAW_DIR="${HOME_DIR}/.openclaw"
SSH_PERSISTENT="${OPENCLAW_DIR}/ssh"

# Symlink ~/.ssh → persistent location (if keys exist)
if [ -d "$SSH_PERSISTENT" ]; then
    rm -rf "${HOME_DIR}/.ssh" 2>/dev/null
    ln -sf "$SSH_PERSISTENT" "${HOME_DIR}/.ssh"
fi

# Restore git config from persistent store (if saved)
if [ -f "${OPENCLAW_DIR}/gitconfig" ]; then
    cp "${OPENCLAW_DIR}/gitconfig" "${HOME_DIR}/.gitconfig" 2>/dev/null
fi

# Hand off to the original command
exec "$@"
