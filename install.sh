#!/usr/bin/env bash
# ThreeJS Widget Viewer — installer
# Usage: bash install.sh [--widgets-only]

set -e

PLASMOID_ID="com.xenotrek.threejs-viewer"
PLASMOID_SRC="$(cd "$(dirname "$0")" && pwd)/$PLASMOID_ID"
INSTALL_DIR="$HOME/.local/share/plasma/plasmoids/$PLASMOID_ID"

if [[ "$1" == "--widgets-only" ]]; then
    echo "[*] Syncing widgets only..."
    cp -r "$PLASMOID_SRC/contents/widgets/." "$INSTALL_DIR/contents/widgets/"
    echo "[+] Done. Reopen widget config to see new entries."
    exit 0
fi

echo "[*] Installing $PLASMOID_ID..."
[[ -d "$INSTALL_DIR" ]] && rm -rf "$INSTALL_DIR"
cp -r "$PLASMOID_SRC" "$HOME/.local/share/plasma/plasmoids/"
echo "[+] Files copied to $INSTALL_DIR"

# Ensure env file exists
ENV_FILE="$HOME/.config/plasma-workspace/env/webengine.sh"
mkdir -p "$(dirname "$ENV_FILE")"
if ! grep -q "QML_XHR_ALLOW_FILE_READ" "$ENV_FILE" 2>/dev/null; then
    echo 'export QML_XHR_ALLOW_FILE_READ=1' >> "$ENV_FILE"
    echo "[+] Added QML_XHR_ALLOW_FILE_READ to $ENV_FILE"
fi
if ! grep -q "QTWEBENGINE_CHROMIUM_FLAGS" "$ENV_FILE" 2>/dev/null; then
    echo 'export QTWEBENGINE_CHROMIUM_FLAGS="--no-sandbox"' >> "$ENV_FILE"
    echo "[+] Added QTWEBENGINE_CHROMIUM_FLAGS to $ENV_FILE"
fi

echo ""
echo "[*] Restarting plasmashell..."
# Source the env file so plasmashell inherits the vars immediately (no logout needed)
# shellcheck disable=SC1090
[[ -f "$ENV_FILE" ]] && source "$ENV_FILE"
killall plasmashell 2>/dev/null || true
sleep 1
plasmashell --replace &
disown

echo ""
echo "[+] Install complete."
echo ""
echo "    NOTE: Log out and back in once so env vars take effect."
echo ""
echo "    Test window:"
echo "    QML_XHR_ALLOW_FILE_READ=1 plasmawindowed $PLASMOID_ID"
echo ""
echo "    Add widgets later:"
echo "    1. Drop .html into $INSTALL_DIR/contents/widgets/"
echo "    2. Add entry to manifest.json in that folder"
echo "    3. bash install.sh --widgets-only"
