# 🌙 Dotfiles

My personal dotfiles for Arch Linux with Hyprland and the Caelestia desktop environment.

![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat&logo=arch-linux&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-58E1FF?style=flat&logo=hyprland&logoColor=black)
![NVIDIA](https://img.shields.io/badge/NVIDIA-76B900?style=flat&logo=nvidia&logoColor=white)

## ✨ Features

- **Window Manager**: [Hyprland](https://hyprland.org/) - A dynamic tiling Wayland compositor
- **Shell Framework**: [Caelestia](https://github.com/Caelestia-shell/caelestia-meta) - Modern desktop shell with Quickshell
- **Shell**: Fish with Starship prompt
- **Terminal**: Foot
- **Theme**: Dynamic color scheme based on wallpaper (via matugen)
- **Cursor**: Bibata-Modern-Classic (24px)
- **GRUB Theme**: Tartarus
- **Login Manager**: SDDM with Astronaut theme (Japanese Aesthetic variant)
- **GPU**: NVIDIA with nvidia-open-dkms driver

## 📦 Included Configurations

| Category | Files | Description |
|----------|-------|-------------|
| **Caelestia** | `shell.json`, `hypr-vars.conf`, `hypr-user.conf` | Quickshell & Hyprland overrides |
| **VS Code** | `settings.json` | Editor settings with Caelestia theme |
| **GTK** | `gtk-3.0/`, `gtk-4.0/` | GTK settings and cursor theme |
| **Icons** | `icons/default/` | System cursor configuration |
| **GRUB** | `grub/grub` | Bootloader with Tartarus theme |
| **SDDM** | `sddm/sddm.conf` | Login manager theme |

## 🚀 Quick Start

### Prerequisites

- Fresh Arch Linux installation
- Internet connection
- `git` installed (`sudo pacman -S git`)

### Installation

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles

# Run the install script
cd ~/dotfiles
./install.sh
```

The install script will:
1. Install `yay` (AUR helper) if not present
2. Install all packages from `packages.txt`
3. Set up Caelestia desktop environment
4. Configure VS Code, GTK themes, and cursor
5. Set up GRUB and SDDM themes (with prompts)
6. Enable necessary systemd services

## ⌨️ Key Bindings

| Keybind | Action |
|---------|--------|
| `Super + Return` | Open terminal (Foot) |
| `Super + C` | Close window |
| `Super + Space` | App launcher |
| `Super + Alt + Space` | Toggle floating mode |
| `Super + F` | Toggle fullscreen |
| `Super + M` | Open Spotify |
| `Super + N` | Open Notion |
| `Super + B` | Open Blueman |
| `Super + [1-9]` | Switch to workspace |
| `Super + Shift + [1-9]` | Move window to workspace |

## 📁 Repository Structure

```
dotfiles/
├── caelestia/           # Caelestia user configs
│   ├── shell.json       # Quickshell configuration
│   ├── hypr-vars.conf   # Hyprland variable overrides
│   └── hypr-user.conf   # Custom Hyprland config
├── vscode/
│   └── settings.json    # VS Code settings
├── gtk-3.0/
│   └── settings.ini     # GTK 3 settings
├── gtk-4.0/
│   └── settings.ini     # GTK 4 settings
├── icons/
│   └── default/         # Cursor theme config
├── grub/
│   └── grub             # GRUB configuration
├── sddm/
│   └── sddm.conf        # SDDM configuration
├── scripts/             # Utility scripts
├── packages.txt         # List of installed packages
├── install.sh           # Installation script
└── README.md            # This file
```

## 🎨 Customization

### Hyprland Variables

Edit `~/.config/caelestia/hypr-vars.conf` to customize:
- `$cursorTheme` - Cursor theme name
- `$cursorSize` - Cursor size
- `$windowOpacity` - Window transparency (0.0-1.0)

### Quickshell Settings

Edit `~/.config/caelestia/shell.json` to customize:
- Bar settings (height, position, modules)
- Launcher settings
- Notification settings
- Idle timeouts (lock, DPMS, suspend)
- Appearance settings (transparency, blur)

## 📝 Post-Installation

Some things need manual setup:

1. **Tartarus GRUB theme** (if not installed):
   ```bash
   git clone https://github.com/AllJavi/tartarus-grub.git
   cd tartarus-grub && sudo ./install.sh
   ```

2. **Razer peripherals** (add user to plugdev group):
   ```bash
   sudo gpasswd -a $USER plugdev
   ```

3. **VS Code Caelestia theme**:
   Install from VS Code marketplace

4. **Spicetify** (Spotify theming):
   ```bash
   spicetify backup apply
   ```

5. **Reboot** to apply all changes

## 🛠️ Troubleshooting

### OpenRazer not working
```bash
# Enable the daemon
systemctl --user enable --now openrazer-daemon

# Check if user is in plugdev group
groups | grep plugdev
```

### Hyprland not starting
```bash
# Check logs
cat ~/.local/share/hyprland/hyprland.log
```

### NVIDIA issues
Make sure `nvidia-open-dkms` is installed and modules are loaded:
```bash
lsmod | grep nvidia
```

## 📄 License

These dotfiles are released under the MIT License. Feel free to use and modify them as you see fit.

---

*Made with ❤️ on Arch Linux*
