# ThreeJS Widget Viewer — KDE Plasma 6 Plasmoid

A frameless, transparent KDE Plasma 6 applet that renders any local Three.js HTML file directly on your desktop via QtWebEngine.

![preview](preview.png)

---

## Features

- Fully transparent — sits directly on your wallpaper, no panel frame
- Load any HTML/Three.js file from a local widget library
- Switch between widgets from the config panel or right-click menu in edit mode
- Width/height configurable per-instance
- Right-click in edit mode: Next Widget / Previous Widget / Reload

---

## Requirements

- KDE Plasma 6
- `qt6-webengine` package installed

---

## Install

### From KDE Store
Search "ThreeJS Widget Viewer" in **Add Widgets → Get New Widgets**.

### Manual
```bash
git clone https://github.com/numbpill3d/threejs-widget-viewer
cd threejs-widget-viewer
bash install.sh
```

---

## Required environment variables

Create `~/.config/plasma-workspace/env/webengine.sh` containing:

```bash
export QTWEBENGINE_CHROMIUM_FLAGS="--no-sandbox"
export QML_XHR_ALLOW_FILE_READ=1
```

Then **log out and back in**. These are required for WebEngine to load local HTML files inside Plasma.

---

## Adding your own widgets

1. Drop your `.html` file into:
   ```
   ~/.local/share/plasma/plasmoids/com.xenotrek.threejs-viewer/contents/widgets/
   ```

2. Add an entry to `manifest.json` in that folder:
   ```json
   { "name": "My Widget", "file": "my-widget.html" }
   ```

3. Right-click the plasmoid → Configure → select it from the dropdown.

No restart needed.

---

## Widget HTML tips

- Use `body { background: transparent; }` in your widget CSS for true transparency
- Three.js CDN works fine: `https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js`
- The plasmoid injects a transparency override on load so even widgets without transparent bodies will render cleanly

---

## License

GPL-2.0-or-later
