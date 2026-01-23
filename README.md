# dotfiles

My Arch Linux setup with Hyprland and Caelestia.

## What's included

- **Hyprland** - tiling Wayland compositor
- **Caelestia** - desktop shell with Quickshell widgets
- **Fish** - shell with Starship prompt
- **Foot** - terminal (55% opacity)
- **Fuzzel** - app launcher
- **Spicetify** - Spotify theming
- **OpenRazer** - peripheral config (1200 DPI)
- **GRUB** - Tartarus theme + os-prober
- **SDDM** - Astronaut theme

## Configs

| App | Location |
|-----|----------|
| Caelestia | `caelestia/` |
| Hyprland | `hypr/` |
| Fish | `fish/` |
| Foot | `foot/` |
| Fuzzel | `fuzzel/` |
| Spicetify | `spicetify/` |
| btop | `btop/` |
| cava | `cava/` |
| fastfetch | `fastfetch/` |
| OpenRazer | `openrazer/` |
| Polychromatic | `polychromatic/` |
| VS Code | `vscode/` |
| GTK | `gtk-3.0/`, `gtk-4.0/` |
| GRUB | `grub/` |
| SDDM | `sddm/` |
| Wallpapers | `wallpapers/` |

## Installation

Requires Arch with git installed.

```bash
git clone https://github.com/T-silva15/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The script installs yay, 81 packages, copies configs, and sets up services.

## Keybinds

### Apps
| Key | Action |
|-----|--------|
| `Super + T` | Terminal |
| `Super + W` | Browser |
| `Super + F` | File manager |
| `Super + C` | Close window |
| `Super + Super` | Launcher |
| `Super + M` | Spotify |
| `Super + N` | Notion |
| `Super + B` | Blueman |
| `Super + G` | GitHub Desktop |

### Workspaces
| Key | Action |
|-----|--------|
| `Super + [1-9]` | Go to workspace |
| `Super + Alt + [1-9]` | Move window |
| `Ctrl + Super + Arrow` | Previous/Next |

### Utils
| Key | Action |
|-----|--------|
| `Print` | Screenshot |
| `Super + Shift + S` | Region screenshot |
| `Super + Alt + R` | Screen record |
| `Super + Shift + C` | Color picker |
| `Super + V` | Clipboard |
| `Super + .` | Emoji picker |

## Fish aliases

```fish
abbr ga 'git add .'
abbr gc 'git commit -am'
abbr gp 'git push'
abbr gl 'git log'
abbr gs 'git status'
abbr lg 'lazygit'
alias ls='eza --icons --group-directories-first -1'
```

## After install

1. Reboot for all changes to apply
2. Install VS Code Caelestia theme from marketplace
3. If Spicetify didn't apply: `spicetify backup apply`

## Troubleshooting

**OpenRazer:**
```bash
systemctl --user enable --now openrazer-daemon
sudo gpasswd -a $USER plugdev
```

**Hyprland logs:**
```bash
cat ~/.local/share/hyprland/hyprland.log
```

**Spicetify:**
```bash
spicetify restore backup
spicetify backup apply
```
