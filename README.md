# dotfiles

Arch Linux + Hyprland + Caelestia setup.

## Stack

| Component | Software |
|-----------|----------|
| OS | Arch Linux |
| WM | Hyprland |
| Shell | Caelestia (Quickshell) |
| Terminal | Foot |
| Shell | Fish + Starship |
| Launcher | Fuzzel |
| Browser | Firefox |
| File Manager | Dolphin |
| Audio | PipeWire + WirePlumber |
| Bluetooth | BlueZ + Blueman |
| Network | NetworkManager + iwd |
| Display Manager | SDDM (Astronaut theme) |
| Bootloader | GRUB (Tartarus theme) |
| GPU | NVIDIA (open-dkms) |

## Packages (82)

**AUR packages** (installed via yay):
- bibata-cursor-theme
- caelestia-meta (includes caelestia-cli, caelestia-shell)
- linux-wallpaperengine-git
- notion-app-electron
- polychromatic
- spicetify-cli
- spicetify-marketplace-bin
- visual-studio-code-bin
- wallpaperengine-gui
- yay, yay-debug

**Multilib** (steam, 32-bit nvidia libs):
- steam

The install script auto-enables multilib and installs yay.

<details>
<summary>Full package list</summary>

```
amd-ucode
base
base-devel
bibata-cursor-theme
blueman
bluez
bluez-utils
caelestia-meta
discord
dkms
dolphin
dunst
efibootmgr
firefox
fish
git
github-cli
gpicview
grim
grub
gst-plugin-pipewire
htop
hyprland
imagemagick
inter-font
iwd
kitty
libpulse
libva-nvidia-driver
linux
linux-firmware
linux-headers
linux-lts
linux-lts-headers
linux-wallpaperengine-git
nano
network-manager-applet
networkmanager
nodejs
notion-app-electron
noto-fonts-cjk
noto-fonts-emoji
npm
nvidia-open-dkms
openrazer-daemon
openrazer-driver-dkms
os-prober
pavucontrol
pipewire
pipewire-alsa
pipewire-jack
pipewire-pulse
polkit-kde-agent
polychromatic
python-openrazer
qt5-wayland
qt6-virtualkeyboard
qt6-wayland
sddm
slurp
smartmontools
sof-firmware
spicetify-cli
spicetify-marketplace-bin
spotify
steam
unzip
uwsm
vim
visual-studio-code-bin
wallpaperengine-gui
wget
wireless_tools
wireplumber
wofi
xdg-desktop-portal-hyprland
xdg-utils
xorg-server
xorg-xinit
yay
yay-debug
zram-generator
```

</details>

## Configs

### caelestia/
User overrides for Caelestia shell.

| File | Purpose |
|------|---------|
| `shell.json` | Quickshell settings (idle, bar, launcher, etc) |
| `hypr-vars.conf` | Hyprland variable overrides |
| `hypr-user.conf` | Custom Hyprland config |

### hypr/
Hyprland configuration (symlinked from `~/.local/share/caelestia/hypr/`).

| File | Purpose |
|------|---------|
| `hyprland.conf` | Main config entry point |
| `hyprland/variables.conf` | Variables ($terminal, $browser, etc) |
| `hyprland/keybinds.conf` | All keybinds |
| `scripts/wsaction.fish` | Workspace action script |

### fish/
Fish shell config (symlinked from `~/.local/share/caelestia/fish/`).

| File | Purpose |
|------|---------|
| `config.fish` | Main config with aliases |
| `functions/fish_greeting.fish` | Greeting function |

### foot/
Terminal emulator config.

| Setting | Value |
|---------|-------|
| Shell | Fish |
| Font | JetBrains Mono Nerd Font, 12pt |
| Transparency | 55% |
| Cursor | Beam, 1.5px |
| Scrollback | 10000 lines |
| Padding | 25x25 |

### spicetify/
Spotify theming.

| File | Purpose |
|------|---------|
| `config-xpui.ini` | Spicetify config |
| `Themes/caelestia/` | Caelestia theme files |

### btop/
System monitor.

| File | Purpose |
|------|---------|
| `btop.conf` | Main config |
| `themes/caelestia.theme` | Color scheme |

### cava/
Audio visualizer config.

### fastfetch/
System info display config (`config.jsonc`).

### openrazer/
Razer peripheral daemon config.

| File | Purpose |
|------|---------|
| `razer.conf` | Daemon settings |
| `persistence.conf` | DPI persistence (1200 DPI) |

### polychromatic/
Razer GUI app preferences.

### vscode/
VS Code `settings.json`.

### gtk-3.0/ & gtk-4.0/
GTK theme settings (cursor).

### icons/
Cursor theme config (`Bibata-Modern-Classic`).

### grub/
GRUB bootloader config.

- Theme: Tartarus
- os-prober enabled

### sddm/
SDDM login manager config.

- Theme: sddm-astronaut-theme

### wallpapers/
25 wallpapers.

---

## Keybinds

### Variables

```conf
$terminal = foot
$browser = firefox
$fileExplorer = dolphin
```

### Apps

| Keybind | Action |
|---------|--------|
| Super + T | Terminal |
| Super + W | Browser |
| Super + F | File explorer |
| Super + M | Spotify |
| Super + N | Notion |
| Super + B | Blueman |
| Super + G | GitHub Desktop |
| Super + V | Clipboard |
| Super + . | Emoji picker |
| Ctrl + Alt + Escape | qps (process manager) |

### Window Management

| Keybind | Action |
|---------|--------|
| Super + C | Close window |
| Super + Alt + Space | Toggle floating |
| Super + Shift + F | Fullscreen |
| Super + Alt + F | Fullscreen (with border) |
| Super + P | Pin window |
| Super + Arrows | Move focus |
| Super + Shift + Arrows | Move window |
| Super + Z + drag | Move window |
| Super + X + drag | Resize window |
| Super + mouse drag | Move window |
| Super + right-click drag | Resize window |
| Super + - / + | Adjust split ratio |
| Super + Alt + Backslash | Picture-in-picture |
| Ctrl + Super + Backslash | Center window |

### Workspaces

| Keybind | Action |
|---------|--------|
| Super + 1-9,0 | Go to workspace |
| Super + Alt + 1-9,0 | Move window to workspace |
| Ctrl + Super + Left/Right | Previous/next workspace |
| Super + scroll | Cycle workspaces |
| Super + Page Up/Down | Previous/next workspace |
| Ctrl + Super + Shift + Up | Move to special workspace |
| Super + Alt + S | Move to special workspace |

### Window Groups

| Keybind | Action |
|---------|--------|
| Alt + Tab | Cycle group next |
| Shift + Alt + Tab | Cycle group prev |
| Super + , | Toggle group |
| Super + U | Ungroup window |

### Media

| Keybind | Action |
|---------|--------|
| Ctrl + Super + Space | Play/pause |
| Ctrl + Super + = | Next track |
| Ctrl + Super + - | Previous track |
| XF86Audio keys | Volume/play/pause |

### Screenshot & Recording

| Keybind | Action |
|---------|--------|
| Print | Full screenshot to clipboard |
| Super + Shift + S | Region screenshot (freeze) |
| Super + Shift + Alt + S | Region screenshot |
| Super + Alt + R | Record screen with audio |
| Ctrl + Alt + R | Record screen |
| Super + Shift + Alt + R | Record region |
| Super + Shift + C | Color picker |

### Volume & Brightness

| Keybind | Action |
|---------|--------|
| XF86AudioRaiseVolume | Volume up |
| XF86AudioLowerVolume | Volume down |
| XF86AudioMute | Toggle mute |
| Super + Shift + M | Toggle mute |
| XF86MonBrightnessUp/Down | Brightness |

### System

| Keybind | Action |
|---------|--------|
| Super + Super | App launcher |
| Super + L | Lock |
| Super + Shift + L | Suspend |
| Ctrl + Alt + Delete | Session menu |
| Ctrl + Alt + C | Clear notifications |
| Super + K | Show all panels |
| Ctrl + Super + Shift + R | Kill Quickshell |
| Ctrl + Super + Alt + R | Restart Quickshell |

---

## Settings

### Shell (shell.json)

**Idle timeouts:**
- Lock: 30 min
- DPMS off: 45 min  
- Suspend: 60 min

**Transparency:**
- Base: 50%
- Layers: 35%

**Bar:**
- Persistent: yes
- Show on hover: yes
- Per-monitor workspaces: yes

### Foot terminal

- Font: JetBrains Mono Nerd Font, 12pt
- Alpha: 0.55
- Cursor: beam
- Padding: 25x25

### Hyprland variables

```conf
$cursorTheme = Bibata-Modern-Classic
$cursorSize = 24
$windowOpacity = 0.90
$windowRounding = 10
$windowGapsIn = 10
$windowGapsOut = 40
$volumeStep = 10
```

### Fish aliases

```fish
# Git
abbr ga 'git add .'
abbr gc 'git commit -am'
abbr gp 'git push'
abbr gpl 'git pull'
abbr gl 'git log'
abbr gs 'git status'
abbr gst 'git stash'
abbr gsp 'git stash pop'
abbr gsw 'git switch'
abbr gsm 'git switch main'
abbr gb 'git branch'
abbr gbd 'git branch -d'
abbr gco 'git checkout'
abbr gsh 'git show'
abbr gd 'git diff'
abbr lg 'lazygit'

# ls
alias ls='eza --icons --group-directories-first -1'
abbr l 'ls'
abbr ll 'ls -l'
abbr la 'ls -a'
abbr lla 'ls -la'
```

### Razer

- Device: Viper V2 Pro
- DPI: 1200
- Daemon: openrazer
- GUI: polychromatic

---

## Services

### System (systemctl)
- bluetooth.service
- NetworkManager.service
- sddm.service

### User (systemctl --user)
- openrazer-daemon.service
- pipewire.socket
- pipewire-pulse.socket
- wireplumber.service

---

## Installation

```bash
git clone https://github.com/T-silva15/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

### What the script does

1. Enables multilib repository (for Steam)
2. Installs yay (AUR helper)
3. Installs all 82 packages (official + AUR)
4. Sets up Caelestia desktop with Hyprland
5. Copies all configs
6. Sets up GRUB (Tartarus theme) + SDDM (Astronaut theme)
7. Enables systemd services
8. Applies Spicetify theme

The script:
1. Installs yay (AUR helper)
2. Installs all 82 packages
3. Copies all configs to their locations
4. Sets up Caelestia symlinks
5. Sets up GRUB with Tartarus theme and os-prober
6. Sets up SDDM with Astronaut theme
7. Enables systemd services
8. Applies Spicetify theme

### Post-install

1. Reboot
2. Install VS Code Caelestia theme from marketplace
3. If Spicetify failed: `spicetify backup apply`

---

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

**NVIDIA:**
```bash
lsmod | grep nvidia
# Should show nvidia, nvidia_modeset, nvidia_uvm
```
