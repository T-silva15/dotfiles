# 🌙 Dotfiles

My personal dotfiles for Arch Linux with Hyprland and the Caelestia desktop environment.

![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat&logo=arch-linux&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-58E1FF?style=flat&logo=hyprland&logoColor=black)
![NVIDIA](https://img.shields.io/badge/NVIDIA-76B900?style=flat&logo=nvidia&logoColor=white)

## ✨ Features

- **Window Manager**: [Hyprland](https://hyprland.org/) - A dynamic tiling Wayland compositor
- **Shell Framework**: [Caelestia](https://github.com/Caelestia-shell/caelestia-meta) - Modern desktop shell with Quickshell
- **Shell**: Fish with Starship prompt + custom aliases
- **Terminal**: Foot (55% transparency)
- **Launcher**: Fuzzel with Caelestia colors
- **Theme**: Dynamic color scheme based on wallpaper (via matugen)
- **Cursor**: Bibata-Modern-Classic (24px)
- **GRUB Theme**: Tartarus
- **Login Manager**: SDDM with Astronaut theme (Japanese Aesthetic variant)
- **GPU**: NVIDIA with nvidia-open-dkms driver
- **Spotify**: Spicetify with Caelestia theme + Marketplace
- **Razer Peripherals**: OpenRazer + Polychromatic

## 📦 Included Configurations

| Category | Files | Description |
|----------|-------|-------------|
| **Caelestia** | `shell.json`, `hypr-vars.conf`, `hypr-user.conf` | Quickshell & Hyprland overrides |
| **Hyprland** | `hyprland.conf`, `variables.conf`, `keybinds.conf` | Full Hyprland configuration |
| **Fish** | `config.fish`, `functions/` | Shell config with git aliases |
| **Foot** | `foot.ini` | Terminal with transparency |
| **Fuzzel** | `fuzzel.ini` | Application launcher |
| **VS Code** | `settings.json` | Editor settings |
| **Spicetify** | `config-xpui.ini`, `Themes/caelestia/` | Spotify theming |
| **btop** | `btop.conf`, `themes/caelestia.theme` | System monitor |
| **cava** | `config` | Audio visualizer |
| **fastfetch** | `config.jsonc` | System info display |
| **OpenRazer** | `razer.conf` | Razer daemon config |
| **Polychromatic** | `preferences.json` | Razer GUI config |
| **GTK** | `gtk-3.0/`, `gtk-4.0/` | GTK settings |
| **Icons** | `icons/default/` | Cursor configuration |
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
2. Install all packages from `packages.txt` (81 packages)
3. Set up Caelestia + Hyprland desktop environment
4. Configure Fish shell with aliases
5. Set up Foot terminal, Fuzzel launcher
6. Configure Spicetify for Spotify theming
7. Set up btop, cava, fastfetch
8. Configure OpenRazer + Polychromatic for Razer devices
9. Configure VS Code, GTK themes, and cursor
10. Set up GRUB and SDDM themes (with prompts)
11. Enable necessary systemd services

## ⌨️ Key Bindings

### General
| Keybind | Action |
|---------|--------|
| `Super + T` | Open terminal (Foot) |
| `Super + W` | Open browser (Firefox) |
| `Super + F` | Open file explorer (Dolphin) |
| `Super + C` | Close window |
| `Super + Super` | App launcher |
| `Super + Alt + Space` | Toggle floating mode |
| `Super + Shift + F` | Toggle fullscreen |

### Custom App Shortcuts
| Keybind | Action |
|---------|--------|
| `Super + M` | Open Spotify |
| `Super + N` | Open Notion |
| `Super + B` | Open Blueman |
| `Super + G` | Open GitHub Desktop |

### Workspaces
| Keybind | Action |
|---------|--------|
| `Super + [1-9]` | Switch to workspace |
| `Super + Alt + [1-9]` | Move window to workspace |
| `Ctrl + Super + Left/Right` | Previous/Next workspace |
| `Super + Mouse Scroll` | Cycle workspaces |

### Utilities
| Keybind | Action |
|---------|--------|
| `Print` | Screenshot (full screen) |
| `Super + Shift + S` | Screenshot region (freeze) |
| `Super + Alt + R` | Record screen with sound |
| `Super + Shift + C` | Color picker |
| `Super + V` | Clipboard history |
| `Super + .` | Emoji picker |

## 📁 Repository Structure

```
dotfiles/
├── caelestia/           # Caelestia user configs
│   ├── shell.json       # Quickshell configuration
│   ├── hypr-vars.conf   # Hyprland variable overrides
│   └── hypr-user.conf   # Custom Hyprland config
├── hypr/                # Hyprland configuration
│   ├── hyprland.conf    # Main config
│   ├── variables.conf   # Variables and settings
│   ├── hyprland/
│   │   └── keybinds.conf
│   └── scripts/
│       └── wsaction.fish
├── fish/                # Fish shell
│   ├── config.fish      # Main config with aliases
│   └── functions/       # Custom functions
├── foot/
│   └── foot.ini         # Terminal config
├── fuzzel/
│   └── fuzzel.ini       # Launcher config
├── spicetify/           # Spotify theming
│   ├── config-xpui.ini
│   └── Themes/caelestia/
├── btop/                # System monitor
│   ├── btop.conf
│   └── themes/caelestia.theme
├── cava/
│   └── config           # Audio visualizer
├── fastfetch/
│   └── config.jsonc     # System info
├── openrazer/
│   └── razer.conf       # Razer daemon
├── polychromatic/
│   └── preferences.json # Razer GUI
├── vscode/
│   └── settings.json
├── gtk-3.0/ & gtk-4.0/
│   └── settings.ini
├── icons/default/       # Cursor config
├── grub/grub            # GRUB config
├── sddm/sddm.conf       # SDDM config
├── packages.txt         # Package list (81 packages)
├── install.sh           # Installation script
└── README.md
```

## 🎨 Customization

### Hyprland Variables (`~/.config/caelestia/hypr-vars.conf`)
```conf
$cursorTheme = Bibata-Modern-Classic
$cursorSize = 24
$windowOpacity = 0.90
```

### Quickshell Settings (`~/.config/caelestia/shell.json`)
- Idle timeouts: Lock (30min), DPMS (45min), Suspend (60min)
- Transparency enabled (0.5 base)
- Bar and launcher settings
- Notification settings

### Fish Aliases
```fish
# Git shortcuts
abbr ga 'git add .'
abbr gc 'git commit -am'
abbr gp 'git push'
abbr gl 'git log'
abbr gs 'git status'
abbr lg 'lazygit'

# Better ls with eza
alias ls='eza --icons --group-directories-first -1'
```

## 🖱️ Razer Configuration

DPI is set to **1200** for the Razer Viper V2 Pro via OpenRazer.

To change DPI:
```bash
# Using polychromatic GUI
polychromatic-controller

# Or via command line
razercfg -d <device> -r 1 -D <dpi>
```

## 📝 Post-Installation

Some things need manual setup:

1. **Tartarus GRUB theme** (if not installed):
   ```bash
   git clone https://github.com/AllJavi/tartarus-grub.git
   cd tartarus-grub && sudo ./install.sh
   ```

2. **VS Code Caelestia theme**:
   Install from VS Code marketplace

3. **Apply Spicetify** (if auto-apply failed):
   ```bash
   spicetify backup apply
   ```

4. **Reboot** to apply all changes

## 🛠️ Troubleshooting

### OpenRazer not working
```bash
# Enable the daemon
systemctl --user enable --now openrazer-daemon

# Check if user is in plugdev group
groups | grep plugdev

# If not, add yourself
sudo gpasswd -a $USER plugdev
```

### Hyprland not starting
```bash
# Check logs
cat ~/.local/share/hyprland/hyprland.log
```

### Spicetify issues
```bash
# Restore Spotify and reapply
spicetify restore backup
spicetify backup apply
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
