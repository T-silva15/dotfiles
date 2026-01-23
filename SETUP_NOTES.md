# Setup Notes

This document contains detailed notes about the configuration steps that were taken to set up this system.

## 🖱️ Mouse DPI Configuration (Razer Viper V2 Pro)

The DPI was set to **1200** using OpenRazer:

```bash
# Enable OpenRazer daemon
systemctl --user enable --now openrazer-daemon

# Add user to plugdev group
sudo gpasswd -a $USER plugdev

# Set DPI (requires polychromatic or direct OpenRazer control)
# The persistence.conf file saves DPI settings
```

The DPI settings are stored in `openrazer/persistence.conf`.

## 🔒 Idle Timeouts

Configured in `caelestia/shell.json`:
- **Lock screen**: 30 minutes (1800 seconds)
- **DPMS (display off)**: 45 minutes (2700 seconds)  
- **Suspend**: 60 minutes (3600 seconds)

## 🎨 Transparency Settings

- **Window opacity**: 90% (`hypr-vars.conf`: `$windowOpacity = 0.90`)
- **Foot terminal**: 55% transparency (`foot.ini`: `alpha=0.55`)
- **Quickshell transparency**: Enabled with 0.5 base

## 🖼️ Cursor Theme

- **Theme**: Bibata-Modern-Classic
- **Size**: 24px

Configured in:
- `caelestia/hypr-vars.conf`
- `gtk-3.0/settings.ini`
- `gtk-4.0/settings.ini`
- `icons/default/index.theme`

## 🔑 Custom Keybinds Added

In `hypr/hyprland/keybinds.conf`:
- `Super + M` → Spotify
- `Super + N` → Notion
- `Super + B` → Blueman Manager
- `Super + G` → GitHub Desktop

## 🎵 Spicetify Setup

1. Install spicetify-cli and marketplace from AUR
2. Theme: `caelestia` with custom colors
3. Custom apps: `marketplace`, `lyrics-plus`

```bash
spicetify backup apply
```

## 💡 OpenRazer + Polychromatic

- **OpenRazer daemon**: Enabled as user service
- **Polychromatic**: GUI for Razer devices
- **Tray autostart**: Enabled

## 🚀 GRUB Configuration

- **Theme**: Tartarus (auto-installed by install.sh)
- **os-prober**: Enabled for dual-boot detection
- **Timeout**: 5 seconds

## 🖥️ SDDM Configuration

- **Theme**: sddm-astronaut-theme (Japanese Aesthetic variant)

## 🐟 Fish Shell

- **Starship prompt**: Custom config via Caelestia
- **Aliases**: git shortcuts, eza for ls
- **Default shell**: Set via `chsh -s $(which fish)`

## 📦 Key AUR Packages

- `caelestia-meta` - Desktop shell framework
- `bibata-cursor-theme` - Cursor theme
- `visual-studio-code-bin` - VS Code
- `spotify` + `spicetify-cli` + `spicetify-marketplace-bin`
- `notion-app-electron` - Notion
- `sddm-astronaut-theme` - Login manager theme
- `openrazer-daemon` + `polychromatic` - Razer support
- `yay` - AUR helper

## 🔧 Systemd Services Enabled

### System services:
- `NetworkManager`
- `bluetooth`
- `sddm`

### User services:
- `openrazer-daemon`
- `pipewire`
- `pipewire-pulse`
- `wireplumber`

## 🖼️ Font Configuration

Installed fonts:
- `inter-font` - UI font
- `noto-fonts-emoji` - Emoji support
- `noto-fonts-cjk` - CJK character support
- JetBrains Mono Nerd Font (for terminal)

## 🎨 Theming

All apps use the **Caelestia** dynamic theme system:
- Colors generated from wallpaper using `matugen`
- Consistent theming across:
  - Hyprland
  - Quickshell (bar, launcher, notifications)
  - Foot terminal (colors via sequences.txt)
  - btop
  - cava
  - Spotify (via Spicetify)
  - fuzzel
  - VS Code
