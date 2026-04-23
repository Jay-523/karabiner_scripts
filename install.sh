#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/karabiner"
REPO_DEST="$CONFIG_DIR/karabiner_scripts"
SRC_JSON="$SCRIPT_DIR/karabiner.json"
DEST_JSON="$CONFIG_DIR/karabiner.json"

if [[ ! -f "$SRC_JSON" ]]; then
  echo "error: $SRC_JSON not found" >&2
  exit 1
fi

mkdir -p "$CONFIG_DIR"

echo "==> Quitting Karabiner-Elements (remaps will pause briefly)"
osascript -e 'tell application "Karabiner-Elements" to quit' 2>/dev/null || true
pkill -x "Karabiner-Elements" 2>/dev/null || true
pkill -f "karabiner_console_user_server" 2>/dev/null || true
sleep 2

if [[ -f "$DEST_JSON" ]]; then
  BACKUP="$DEST_JSON.backup.$(date +%Y%m%d-%H%M%S)"
  echo "==> Backing up existing karabiner.json -> $BACKUP"
  cp "$DEST_JSON" "$BACKUP"
fi

if [[ "$SCRIPT_DIR" != "$REPO_DEST" ]]; then
  echo "==> Syncing repo to $REPO_DEST"
  mkdir -p "$REPO_DEST"
  rsync -a --delete --exclude='.git' "$SCRIPT_DIR/" "$REPO_DEST/"
fi

echo "==> Installing karabiner.json -> $DEST_JSON"
cp "$SRC_JSON" "$DEST_JSON"

echo "==> Relaunching Karabiner-Elements"
open -a "Karabiner-Elements"

echo "Done."
