#!/usr/bin/env bash
# Copy widget HTML files into the installed plasmoid
# Usage: bash deploy-widgets.sh /path/to/your/html/files/

WIDGETS_DEST="$HOME/.local/share/plasma/plasmoids/com.xenotrek.threejs-viewer/contents/widgets"
SRC_DIR="${1:-.}"

if [[ ! -d "$WIDGETS_DEST" ]]; then
    echo "[!] Plasmoid not installed yet. Run install.sh first."
    exit 1
fi

echo "[*] Copying widgets from $SRC_DIR ..."
cp "$SRC_DIR"/*.html "$WIDGETS_DEST/" 2>/dev/null && echo "[+] HTML files copied." || echo "[!] No HTML files found."
[[ -f "$SRC_DIR/manifest.json" ]] && cp "$SRC_DIR/manifest.json" "$WIDGETS_DEST/" && echo "[+] manifest.json copied."
echo "[+] Done."
