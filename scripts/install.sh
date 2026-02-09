#!/bin/bash
# install.sh — Build Vox release and install to ~/.local/bin, restart launchd agent
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL_PATH="$HOME/.local/bin/Vox"
PLIST_LABEL="com.id8labs.vox"

echo "[Vox] Building release..."
swift build --package-path "$SCRIPT_DIR" -c release 2>&1 | tail -3

echo "[Vox] Installing to $INSTALL_PATH..."
cp "$SCRIPT_DIR/.build/arm64-apple-macosx/release/Vox" "$INSTALL_PATH"
chmod +x "$INSTALL_PATH"

echo "[Vox] Restarting launchd agent..."
launchctl kickstart -k "gui/$(id -u)/$PLIST_LABEL" 2>/dev/null || {
    launchctl stop "$PLIST_LABEL" 2>/dev/null
    sleep 1
    launchctl start "$PLIST_LABEL" 2>/dev/null
}

sleep 2
if launchctl list | grep -q "$PLIST_LABEL"; then
    echo "[Vox] Running. $(ls -lh "$INSTALL_PATH" | awk '{print $5}') release binary."
else
    echo "[Vox] Warning: launchd agent not running. Check logs at ~/Library/Logs/claude-automation/vox/"
fi
