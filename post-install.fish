#!/usr/bin/env fish

# ╭─────────────────────────────────────────────────────────────────╮
# │  Caelestia Post-Install Script                                  │
# │  Automates additional system customizations after caelestia     │
# │  dotfiles installation                                          │
# ╰─────────────────────────────────────────────────────────────────╯

argparse -n 'post-install.fish' -X 0 \
    'h/help' \
    'noconfirm' \
    'aur-helper=!contains -- "$_flag_value" yay paru' \
    'skip-grub' \
    'skip-sddm' \
    'skip-cursor' \
    'skip-fonts' \
    'skip-razer' \
    'skip-steam' \
    'skip-bluetooth' \
    'skip-keybinds' \
    -- $argv
or exit

# Print help
if set -q _flag_h
    echo 'usage: ./post-install.fish [-h] [--noconfirm] [--aur-helper=yay|paru] [--skip-*]'
    echo
    echo 'Caelestia post-install script for additional system customizations.'
    echo
    echo 'options:'
    echo '  -h, --help                  show this help message and exit'
    echo '  --noconfirm                 do not confirm package installation'
    echo '  --aur-helper=[yay|paru]     the AUR helper to use (default: paru)'
    echo
    echo 'skip options:'
    echo '  --skip-grub                 skip GRUB Tartarus theme installation'
    echo '  --skip-sddm                 skip SDDM Astronaut theme installation'
    echo '  --skip-cursor               skip Bibata cursor theme installation'
    echo '  --skip-fonts                skip font installation (Inter, Noto CJK, Emoji)'
    echo '  --skip-razer                skip OpenRazer/Polychromatic installation'
    echo '  --skip-steam                skip Steam installation'
    echo '  --skip-bluetooth            skip Bluetooth tools installation'
    echo '  --skip-keybinds             skip keybind customizations'
    exit
end

# ─────────────────────────────────────────────────────────────────
# Helper Functions
# ─────────────────────────────────────────────────────────────────

function _out -a colour text
    set_color $colour
    echo $argv[3..] -- ":: $text"
    set_color normal
end

function log -a text
    _out cyan $text $argv[2..]
end

function warn -a text
    _out yellow $text $argv[2..]
end

function error -a text
    _out red $text $argv[2..]
end

function success -a text
    _out green $text $argv[2..]
end

function input -a text
    _out blue $text $argv[2..]
end

function sh-read
    sh -c 'read a && echo -n "$a"' || exit 1
end

function confirm -a prompt
    if set -q noconfirm
        return 0
    end
    input "$prompt [Y/n] " -n
    set -l choice (sh-read)
    test "$choice" != 'n' -a "$choice" != 'N'
end

# ─────────────────────────────────────────────────────────────────
# Variables
# ─────────────────────────────────────────────────────────────────

set -q _flag_noconfirm && set noconfirm '--noconfirm'
set -q _flag_aur_helper && set aur_helper $_flag_aur_helper || set aur_helper paru
set -q XDG_CONFIG_HOME && set config $XDG_CONFIG_HOME || set config $HOME/.config
set -q XDG_STATE_HOME && set state $XDG_STATE_HOME || set state $HOME/.local/state

# ─────────────────────────────────────────────────────────────────
# Startup
# ─────────────────────────────────────────────────────────────────

set_color magenta
echo '╭─────────────────────────────────────────────────────────────╮'
echo '│     Caelestia Post-Install Script                           │'
echo '│     Additional system customizations                        │'
echo '╰─────────────────────────────────────────────────────────────╯'
set_color normal

log 'This script will install additional customizations:'
echo '  • GRUB Tartarus theme (gruvbox material)'
echo '  • SDDM Astronaut theme (Japanese aesthetic)'
echo '  • Bibata cursor theme'
echo '  • Fonts: Inter, Noto CJK, Noto Emoji'
echo '  • OpenRazer + Polychromatic (Razer peripherals)'
echo '  • Steam with multilib'
echo '  • Bluetooth tools (Blueman)'
echo '  • Shell.json configuration (idle timeouts, celsius)'
echo '  • Custom keybinds'
echo

if ! set -q noconfirm
    if ! confirm 'Continue with installation?'
        log 'Aborted.'
        exit 0
    end
end

# ─────────────────────────────────────────────────────────────────
# GRUB Tartarus Theme
# ─────────────────────────────────────────────────────────────────

if ! set -q _flag_skip_grub
    log 'Installing GRUB Tartarus theme...'
    
    # Install grub and os-prober
    sudo pacman -S --needed grub os-prober $noconfirm
    
    # Clone and install theme
    if test -d /tmp/grub-theme-tartarus
        rm -rf /tmp/grub-theme-tartarus
    end
    git clone https://github.com/AllJavi/tartarus-grub.git /tmp/grub-theme-tartarus
    sudo cp -r /tmp/grub-theme-tartarus/tartarus /usr/share/grub/themes/
    rm -rf /tmp/grub-theme-tartarus
    
    # Configure GRUB
    if ! grep -q 'GRUB_THEME=.*tartarus' /etc/default/grub
        sudo sed -i 's|^#*GRUB_THEME=.*|GRUB_THEME="/usr/share/grub/themes/tartarus/theme.txt"|' /etc/default/grub
    end
    if grep -q '^GRUB_DISABLE_OS_PROBER=true' /etc/default/grub
        sudo sed -i 's|^GRUB_DISABLE_OS_PROBER=true|GRUB_DISABLE_OS_PROBER=false|' /etc/default/grub
    else if ! grep -q 'GRUB_DISABLE_OS_PROBER' /etc/default/grub
        echo 'GRUB_DISABLE_OS_PROBER=false' | sudo tee -a /etc/default/grub > /dev/null
    end
    
    # Regenerate GRUB config
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    
    success 'GRUB Tartarus theme installed!'
end

# ─────────────────────────────────────────────────────────────────
# SDDM Astronaut Theme
# ─────────────────────────────────────────────────────────────────

if ! set -q _flag_skip_sddm
    log 'Installing SDDM Astronaut theme...'
    
    # Install SDDM and dependencies
    sudo pacman -S --needed sddm qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg $noconfirm
    
    # Clone theme
    if test -d /tmp/sddm-astronaut-theme
        rm -rf /tmp/sddm-astronaut-theme
    end
    git clone https://github.com/Keyitdev/sddm-astronaut-theme.git /tmp/sddm-astronaut-theme
    
    # Install theme
    sudo cp -r /tmp/sddm-astronaut-theme /usr/share/sddm/themes/sddm-astronaut-theme
    sudo cp /tmp/sddm-astronaut-theme/Fonts/* /usr/share/fonts/ 2>/dev/null
    
    # Set Japanese Aesthetic variant
    sudo sed -i 's|ConfigFile=.*|ConfigFile="Themes/japanese_aesthetic.conf"|' /usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop
    
    # Configure SDDM
    echo '[Theme]
Current=sddm-astronaut-theme

[General]
InputMethod=qtvirtualkeyboard' | sudo tee /etc/sddm.conf > /dev/null
    
    # Enable SDDM
    sudo systemctl enable sddm
    
    rm -rf /tmp/sddm-astronaut-theme
    success 'SDDM Astronaut theme installed!'
end

# ─────────────────────────────────────────────────────────────────
# Cursor Theme (Bibata)
# ─────────────────────────────────────────────────────────────────

if ! set -q _flag_skip_cursor
    log 'Installing Bibata cursor theme...'
    
    $aur_helper -S --needed bibata-cursor-theme $noconfirm
    
    # Configure in hypr-vars.conf
    set -l hypr_vars $config/caelestia/hypr-vars.conf
    mkdir -p (dirname $hypr_vars)
    
    # Add cursor config if not already present
    if ! grep -q 'cursorTheme' $hypr_vars 2>/dev/null
        echo '# Cursor theme
$cursorTheme = Bibata-Modern-Classic
$cursorSize = 24' >> $hypr_vars
    end
    
    # GTK cursor settings
    mkdir -p $config/gtk-3.0 $config/gtk-4.0
    for gtk_ver in gtk-3.0 gtk-4.0
        if ! grep -q 'gtk-cursor-theme-name' $config/$gtk_ver/settings.ini 2>/dev/null
            echo '[Settings]
gtk-cursor-theme-name=Bibata-Modern-Classic
gtk-cursor-theme-size=24' >> $config/$gtk_ver/settings.ini
        end
    end
    
    # Default cursor
    mkdir -p $HOME/.icons/default
    echo '[Icon Theme]
Name=Default
Comment=Default Cursor Theme
Inherits=Bibata-Modern-Classic' > $HOME/.icons/default/index.theme
    
    success 'Bibata cursor theme installed!'
end

# ─────────────────────────────────────────────────────────────────
# Fonts
# ─────────────────────────────────────────────────────────────────

if ! set -q _flag_skip_fonts
    log 'Installing fonts...'
    
    sudo pacman -S --needed \
        inter-font \
        noto-fonts-cjk \
        noto-fonts-emoji \
        $noconfirm
    
    fc-cache -fv
    
    success 'Fonts installed!'
end

# ─────────────────────────────────────────────────────────────────
# OpenRazer + Polychromatic
# ─────────────────────────────────────────────────────────────────

if ! set -q _flag_skip_razer
    log 'Installing OpenRazer and Polychromatic...'
    
    $aur_helper -S --needed openrazer-daemon openrazer-driver-dkms python-openrazer polychromatic $noconfirm
    
    # Add user to openrazer group
    if ! groups $USER | grep -q openrazer
        sudo gpasswd -a $USER openrazer
        warn 'Added user to openrazer group. Please log out and back in for this to take effect.'
    end
    
    # Enable daemon
    systemctl --user enable openrazer-daemon
    
    success 'OpenRazer and Polychromatic installed!'
    log 'Note: You may need to reboot for the driver to load.'
end

# ─────────────────────────────────────────────────────────────────
# Steam
# ─────────────────────────────────────────────────────────────────

if ! set -q _flag_skip_steam
    log 'Installing Steam...'
    
    # Enable multilib
    if ! grep -q '^\[multilib\]' /etc/pacman.conf
        log 'Enabling multilib repository...'
        echo '
[multilib]
Include = /etc/pacman.d/mirrorlist' | sudo tee -a /etc/pacman.conf > /dev/null
        sudo pacman -Sy
    end
    
    sudo pacman -S --needed steam $noconfirm
    
    success 'Steam installed!'
end

# ─────────────────────────────────────────────────────────────────
# Bluetooth
# ─────────────────────────────────────────────────────────────────

if ! set -q _flag_skip_bluetooth
    log 'Installing Bluetooth tools...'
    
    sudo pacman -S --needed bluez bluez-utils blueman $noconfirm
    
    # Enable bluetooth service
    sudo systemctl enable --now bluetooth
    
    success 'Bluetooth tools installed!'
end

# ─────────────────────────────────────────────────────────────────
# Shell.json Configuration
# ─────────────────────────────────────────────────────────────────

log 'Configuring shell.json...'

set -l shell_json $config/caelestia/shell.json
mkdir -p (dirname $shell_json)

# Create shell.json with customizations
echo '{
    "useFahrenheit": false,
    "general": {
        "idle": {
            "timeouts": {
                "lock": 1800,
                "dpms": 2700,
                "suspend": 3600
            }
        }
    }
}' > $shell_json

success 'Shell.json configured!'

# ─────────────────────────────────────────────────────────────────
# Keybind Customizations
# ─────────────────────────────────────────────────────────────────

if ! set -q _flag_skip_keybinds
    log 'Applying keybind customizations...'
    
    set -l hypr_vars $config/caelestia/hypr-vars.conf
    mkdir -p (dirname $hypr_vars)
    
    # Only add if file doesn't have these customizations
    if ! grep -q 'kbCloseWindow' $hypr_vars 2>/dev/null
        echo '
# Custom keybind overrides
$browser = firefox
$fileExplorer = dolphin
$kbCloseWindow = Super, C
$kbFileExplorer = Super, F
$kbWindowFullscreen = Super+Shift, F' >> $hypr_vars
    end
    
    # Add custom binds to hypr-user.conf
    set -l hypr_user $config/caelestia/hypr-user.conf
    if ! grep -q 'blueman-manager' $hypr_user 2>/dev/null
        echo '
# Custom keybinds
bind = Super, B, exec, blueman-manager
bind = Super+Shift, V, exec, pavucontrol' >> $hypr_user
    end
    
    success 'Keybind customizations applied!'
end

# ─────────────────────────────────────────────────────────────────
# Enable Dynamic Color Scheme
# ─────────────────────────────────────────────────────────────────

log 'Setting dynamic color scheme...'

if command -q caelestia
    caelestia scheme set dynamic
    caelestia scheme set -v vibrant
end

success 'Dynamic color scheme enabled!'

# ─────────────────────────────────────────────────────────────────
# Done
# ─────────────────────────────────────────────────────────────────

echo
set_color green
echo '╭─────────────────────────────────────────────────────────────╮'
echo '│  ✓ Post-install complete!                                   │'
echo '╰─────────────────────────────────────────────────────────────╯'
set_color normal
echo
log 'Summary of changes:'
echo '  • GRUB: Tartarus theme with os-prober enabled'
echo '  • SDDM: Astronaut theme (Japanese aesthetic)'
echo '  • Cursor: Bibata-Modern-Classic'
echo '  • Fonts: Inter, Noto CJK, Noto Emoji'
echo '  • Razer: OpenRazer daemon + Polychromatic'
echo '  • Gaming: Steam with multilib'
echo '  • Bluetooth: Blueman manager'
echo '  • Shell: Celsius, 30min lock, 45min dpms, 60min suspend'
echo '  • Theme: Dynamic color scheme (vibrant)'
echo
warn 'Recommended actions:'
echo '  1. Reboot to apply GRUB, SDDM, and driver changes'
echo '  2. Log out/in for openrazer group membership'
echo '  3. Run `hyprctl reload` to apply keybind changes'
echo
success 'Done!'
