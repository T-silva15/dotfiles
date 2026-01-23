#!/bin/bash

# ============================================================================
# Dotfiles Installation Script
# Arch Linux + Hyprland + Caelestia Setup
# ============================================================================

# set -e  # Disabled to allow error tracking

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Error tracking
FAILED_PACKAGES=""
FAILED_CONFIGS=""
FAILED_STEPS=""
LOG_FILE="/tmp/dotfiles_install_$(date +%Y%m%d_%H%M%S).log"

# Track failed package
track_failed_package() {
    FAILED_PACKAGES="$FAILED_PACKAGES\n  - $1"
}

# Track failed config
track_failed_config() {
    FAILED_CONFIGS="$FAILED_CONFIGS\n  - $1"
}

# Track failed step
track_failed_step() {
    FAILED_STEPS="$FAILED_STEPS\n  - $1"
}

# Print final summary
print_summary() {
    print_header "Installation Summary"
    
    echo -e "${GREEN}Log file: $LOG_FILE${NC}"
    echo ""
    
    if [ -z "$FAILED_PACKAGES" ] && [ -z "$FAILED_CONFIGS" ] && [ -z "$FAILED_STEPS" ]; then
        echo -e "${GREEN}✓ All installations completed successfully!${NC}"
    else
        if [ -n "$FAILED_PACKAGES" ]; then
            echo -e "${RED}Failed packages:${NC}"
            echo -e "$FAILED_PACKAGES"
            echo ""
        fi
        
        if [ -n "$FAILED_CONFIGS" ]; then
            echo -e "${YELLOW}Failed config copies:${NC}"
            echo -e "$FAILED_CONFIGS"
            echo ""
        fi
        
        if [ -n "$FAILED_STEPS" ]; then
            echo -e "${YELLOW}Failed steps:${NC}"
            echo -e "$FAILED_STEPS"
            echo ""
        fi
        
        echo -e "${YELLOW}Please review the above items and install/configure manually if needed.${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}Recommended post-install steps:${NC}"
    echo "  1. Reboot your system"
    echo "  2. Install VS Code Caelestia theme from marketplace"
    echo "  3. If Spicetify didn't apply: spicetify backup apply"
    echo "  4. Add yourself to plugdev group: sudo gpasswd -a \$USER plugdev"
}


# Helper functions
print_header() {
    echo -e "\n${BLUE}============================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}============================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}→ $1${NC}"
}

# Check if running as root
check_not_root() {
    if [ "$EUID" -eq 0 ]; then
        print_error "Please do not run this script as root"
        exit 1
    fi
}


# Enable multilib repository (needed for Steam and 32-bit libs)
enable_multilib() {
    print_header "Enabling multilib repository"
    
    if grep -q "^\[multilib\]" /etc/pacman.conf; then
        print_success "multilib is already enabled"
    else
        print_info "Enabling multilib in pacman.conf..."
        sudo sed -i '/^#\[multilib\]/,/^#Include/ { s/^#// }' /etc/pacman.conf
        
        if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
            echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf > /dev/null
        fi
        
        sudo pacman -Sy
        print_success "multilib enabled"
    fi
}

# Check if yay is installed, install if not
install_yay() {
    if ! command -v yay &> /dev/null; then
        print_info "Installing yay (AUR helper)..."
        sudo pacman -S --needed --noconfirm git base-devel
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay
        makepkg -si --noconfirm
        cd -
        rm -rf /tmp/yay
        print_success "yay installed"
    else
        print_success "yay is already installed"
    fi
}

# Install packages from packages.txt
install_packages() {
    print_header "Installing Packages"
    
    if [ ! -f "$DOTFILES_DIR/packages.txt" ]; then
        print_error "packages.txt not found!"
        track_failed_step "packages.txt not found"
        return 1
    fi

    # Count packages
    total_packages=$(wc -l < "$DOTFILES_DIR/packages.txt")
    print_info "Installing $total_packages packages..."
    echo ""
    
    # Separate official and AUR packages
    official_packages=""
    aur_packages=""
    
    while read -r pkg; do
        [ -z "$pkg" ] && continue
        if pacman -Si "$pkg" &> /dev/null; then
            official_packages="$official_packages $pkg"
        else
            aur_packages="$aur_packages $pkg"
        fi
    done < "$DOTFILES_DIR/packages.txt"

    # Install official packages one by one to track failures
    if [ -n "$official_packages" ]; then
        print_info "Installing official packages..."
        for pkg in $official_packages; do
            if ! pacman -Q "$pkg" &> /dev/null; then
                if ! sudo pacman -S --needed --noconfirm "$pkg" >> "$LOG_FILE" 2>&1; then
                    print_warning "Failed: $pkg"
                    track_failed_package "$pkg (official)"
                fi
            fi
        done
    fi

    # Install AUR packages one by one to track failures
    if [ -n "$aur_packages" ]; then
        print_info "Installing AUR packages..."
        for pkg in $aur_packages; do
            if ! pacman -Q "$pkg" &> /dev/null; then
                if ! yay -S --needed --noconfirm "$pkg" >> "$LOG_FILE" 2>&1; then
                    print_warning "Failed: $pkg"
                    track_failed_package "$pkg (AUR)"
                fi
            fi
        done
    fi

    print_success "Package installation complete"
}

# Install Caelestia (if not already installed via packages)
install_caelestia() {
    print_header "Setting up Caelestia"
    
    if [ -d "$HOME/.local/share/caelestia" ]; then
        print_success "Caelestia is already installed"
    else
        print_info "Caelestia should be installed via caelestia-meta package"
        print_warning "If not installed, run: yay -S caelestia-meta"
    fi
}

# Setup Caelestia user configs
setup_caelestia_configs() {
    print_header "Setting up Caelestia Configs"
    
    mkdir -p "$HOME/.config/caelestia"
    
    # Copy caelestia user configs
    if [ -d "$DOTFILES_DIR/caelestia" ]; then
        cp "$DOTFILES_DIR/caelestia/shell.json" "$HOME/.config/caelestia/" 2>/dev/null && \
            print_success "Copied shell.json" || print_warning "shell.json not found"
        
        cp "$DOTFILES_DIR/caelestia/hypr-vars.conf" "$HOME/.config/caelestia/" 2>/dev/null && \
            print_success "Copied hypr-vars.conf" || print_warning "hypr-vars.conf not found"
        
        cp "$DOTFILES_DIR/caelestia/hypr-user.conf" "$HOME/.config/caelestia/" 2>/dev/null && \
            print_success "Copied hypr-user.conf" || print_warning "hypr-user.conf not found"
    fi
}

# Setup Hyprland configs
setup_hyprland() {
    print_header "Setting up Hyprland"
    
    mkdir -p "$HOME/.config/hypr/hyprland"
    mkdir -p "$HOME/.config/hypr/scripts"
    
    if [ -d "$DOTFILES_DIR/hypr" ]; then
        cp "$DOTFILES_DIR/hypr/hyprland.conf" "$HOME/.config/hypr/" 2>/dev/null && \
            print_success "Copied hyprland.conf" || print_warning "hyprland.conf not found"
        
        cp "$DOTFILES_DIR/hypr/variables.conf" "$HOME/.config/hypr/" 2>/dev/null && \
            print_success "Copied variables.conf" || print_warning "variables.conf not found"
        
        cp "$DOTFILES_DIR/hypr/hyprland/keybinds.conf" "$HOME/.config/hypr/hyprland/" 2>/dev/null && \
            print_success "Copied keybinds.conf" || print_warning "keybinds.conf not found"
        
        cp "$DOTFILES_DIR/hypr/scripts/wsaction.fish" "$HOME/.config/hypr/scripts/" 2>/dev/null && \
            chmod +x "$HOME/.config/hypr/scripts/wsaction.fish" && \
            print_success "Copied wsaction.fish" || print_warning "wsaction.fish not found"
    fi
}

# Setup Fish shell
setup_fish() {
    print_header "Setting up Fish Shell"
    
    mkdir -p "$HOME/.config/fish/functions"
    
    if [ -d "$DOTFILES_DIR/fish" ]; then
        cp "$DOTFILES_DIR/fish/config.fish" "$HOME/.config/fish/" 2>/dev/null && \
            print_success "Copied config.fish" || print_warning "config.fish not found"
        
        cp -r "$DOTFILES_DIR/fish/functions/"* "$HOME/.config/fish/functions/" 2>/dev/null && \
            print_success "Copied fish functions" || print_warning "No fish functions found"
    fi
    
    # Set fish as default shell if installed
    if command -v fish &> /dev/null; then
        if [ "$SHELL" != "$(which fish)" ]; then
            print_info "Setting fish as default shell..."
            chsh -s "$(which fish)" || print_warning "Could not set fish as default shell"
        fi
    fi
}

# Setup Foot terminal
setup_foot() {
    print_header "Setting up Foot Terminal"
    
    mkdir -p "$HOME/.config/foot"
    
    if [ -f "$DOTFILES_DIR/foot/foot.ini" ]; then
        cp "$DOTFILES_DIR/foot/foot.ini" "$HOME/.config/foot/"
        print_success "Copied foot.ini"
    fi
}

# Setup Fuzzel launcher
setup_fuzzel() {
    print_header "Setting up Fuzzel"
    
    mkdir -p "$HOME/.config/fuzzel"
    
    if [ -f "$DOTFILES_DIR/fuzzel/fuzzel.ini" ]; then
        cp "$DOTFILES_DIR/fuzzel/fuzzel.ini" "$HOME/.config/fuzzel/"
        print_success "Copied fuzzel.ini"
    fi
}

# Setup VS Code settings
setup_vscode() {
    print_header "Setting up VS Code"
    
    VSCODE_CONFIG_DIR="$HOME/.config/Code/User"
    mkdir -p "$VSCODE_CONFIG_DIR"
    
    if [ -f "$DOTFILES_DIR/vscode/settings.json" ]; then
        cp "$DOTFILES_DIR/vscode/settings.json" "$VSCODE_CONFIG_DIR/"
        print_success "Copied VS Code settings"
    fi
    
    # Install Caelestia VS Code integration extension
    if command -v code &> /dev/null; then
        print_info "Installing VS Code Caelestia theme extension..."
        code --install-extension soramanew.caelestia-vscode-integration --force 2>/dev/null && \
            print_success "Installed Caelestia VS Code extension" || \
            print_warning "Could not install VS Code extension - install manually from marketplace"
    fi
}

# Setup Spicetify for Spotify
setup_spicetify() {
    print_header "Setting up Spicetify"
    
    mkdir -p "$HOME/.config/spicetify/Themes/caelestia"
    
    if [ -d "$DOTFILES_DIR/spicetify" ]; then
        # Copy theme files
        cp "$DOTFILES_DIR/spicetify/Themes/caelestia/"* "$HOME/.config/spicetify/Themes/caelestia/" 2>/dev/null && \
            print_success "Copied Spicetify caelestia theme" || print_warning "Spicetify theme not found"
        
        # Copy config (but warn user to update paths)
        if [ -f "$DOTFILES_DIR/spicetify/config-xpui.ini" ]; then
            print_warning "Spicetify config-xpui.ini copied - you may need to run 'spicetify backup apply'"
            cp "$DOTFILES_DIR/spicetify/config-xpui.ini" "$HOME/.config/spicetify/"
        fi
    fi
    
    # Apply spicetify if installed
    if command -v spicetify &> /dev/null; then
        print_info "Running spicetify backup apply..."
        spicetify backup apply 2>/dev/null || print_warning "Spicetify apply failed - run manually"
    fi
}

# Setup btop system monitor
setup_btop() {
    print_header "Setting up btop"
    
    mkdir -p "$HOME/.config/btop/themes"
    
    if [ -d "$DOTFILES_DIR/btop" ]; then
        cp "$DOTFILES_DIR/btop/btop.conf" "$HOME/.config/btop/" 2>/dev/null && \
            print_success "Copied btop.conf" || print_warning "btop.conf not found"
        
        cp "$DOTFILES_DIR/btop/themes/caelestia.theme" "$HOME/.config/btop/themes/" 2>/dev/null && \
            print_success "Copied btop caelestia theme" || print_warning "btop theme not found"
    fi
}

# Setup cava audio visualizer
setup_cava() {
    print_header "Setting up Cava"
    
    mkdir -p "$HOME/.config/cava"
    
    if [ -f "$DOTFILES_DIR/cava/config" ]; then
        cp "$DOTFILES_DIR/cava/config" "$HOME/.config/cava/"
        print_success "Copied cava config"
    fi
}

# Setup fastfetch
setup_fastfetch() {
    print_header "Setting up Fastfetch"
    
    mkdir -p "$HOME/.config/fastfetch"
    
    if [ -f "$DOTFILES_DIR/fastfetch/config.jsonc" ]; then
        cp "$DOTFILES_DIR/fastfetch/config.jsonc" "$HOME/.config/fastfetch/"
        print_success "Copied fastfetch config"
    fi
}

# Setup OpenRazer
setup_openrazer() {
    print_header "Setting up OpenRazer"
    
    mkdir -p "$HOME/.config/openrazer"
    
    if [ -f "$DOTFILES_DIR/openrazer/razer.conf" ]; then
        cp "$DOTFILES_DIR/openrazer/razer.conf" "$HOME/.config/openrazer/"
        print_success "Copied razer.conf"
    fi
    
    # Copy DPI persistence settings
    if [ -f "$DOTFILES_DIR/openrazer/persistence.conf" ]; then
        cp "$DOTFILES_DIR/openrazer/persistence.conf" "$HOME/.config/openrazer/"
        print_success "Copied DPI persistence settings (1200 DPI)"
    fi
    
    # Add user to plugdev group
    if ! groups | grep -q plugdev; then
        print_info "Adding user to plugdev group for Razer peripherals..."
        sudo gpasswd -a "$USER" plugdev || print_warning "Could not add user to plugdev"
    fi
}

# Setup Polychromatic
setup_polychromatic() {
    print_header "Setting up Polychromatic"
    
    mkdir -p "$HOME/.config/polychromatic"
    
    if [ -f "$DOTFILES_DIR/polychromatic/preferences.json" ]; then
        cp "$DOTFILES_DIR/polychromatic/preferences.json" "$HOME/.config/polychromatic/"
        print_success "Copied polychromatic preferences"
    fi
}

# Setup GTK theme settings
setup_gtk() {
    print_header "Setting up GTK Settings"
    
    # GTK 3.0
    mkdir -p "$HOME/.config/gtk-3.0"
    if [ -f "$DOTFILES_DIR/gtk-3.0/settings.ini" ]; then
        cp "$DOTFILES_DIR/gtk-3.0/settings.ini" "$HOME/.config/gtk-3.0/"
        print_success "Copied GTK 3.0 settings"
    fi
    
    # GTK 4.0
    mkdir -p "$HOME/.config/gtk-4.0"
    if [ -f "$DOTFILES_DIR/gtk-4.0/settings.ini" ]; then
        cp "$DOTFILES_DIR/gtk-4.0/settings.ini" "$HOME/.config/gtk-4.0/"
        print_success "Copied GTK 4.0 settings"
    fi
}

# Setup cursor theme
setup_cursor() {
    print_header "Setting up Cursor Theme"
    
    mkdir -p "$HOME/.icons/default"
    if [ -f "$DOTFILES_DIR/icons/default/index.theme" ]; then
        cp "$DOTFILES_DIR/icons/default/index.theme" "$HOME/.icons/default/"
        print_success "Copied cursor theme config"
    fi
}

# Setup GRUB theme (requires sudo)
setup_grub() {
    print_header "Setting up GRUB"
    
    if [ -f "$DOTFILES_DIR/grub/grub" ]; then
        # Ensure os-prober is installed for dual-boot detection
        if ! pacman -Q os-prober &> /dev/null; then
            print_info "Installing os-prober for dual-boot detection..."
            sudo pacman -S --needed --noconfirm os-prober
            print_success "os-prober installed"
        else
            print_success "os-prober is already installed"
        fi
        
        # Check if tartarus theme exists, if not install it
        if [ ! -d "/usr/share/grub/themes/tartarus" ]; then
            print_info "Installing Tartarus GRUB theme..."
            git clone https://github.com/AllJavi/tartarus-grub.git /tmp/tartarus-grub
            cd /tmp/tartarus-grub
            sudo ./install.sh
            cd -
            rm -rf /tmp/tartarus-grub
            print_success "Tartarus theme installed"
        else
            print_success "Tartarus theme is already installed"
        fi
        
        read -p "Do you want to update GRUB config? This requires sudo. (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo cp "$DOTFILES_DIR/grub/grub" /etc/default/grub
            print_info "Regenerating GRUB config (os-prober will detect other OS)..."
            sudo grub-mkconfig -o /boot/grub/grub.cfg
            print_success "GRUB configuration updated with os-prober enabled"
        else
            print_warning "Skipped GRUB configuration"
        fi
    fi
}
# Setup SDDM theme (requires sudo)
setup_sddm() {
    print_header "Setting up SDDM"
    
    if [ -f "$DOTFILES_DIR/sddm/sddm.conf" ]; then
        # Check if sddm-astronaut-theme exists
        if [ ! -d "/usr/share/sddm/themes/sddm-astronaut-theme" ]; then
            print_info "Installing sddm-astronaut-theme from AUR..."
            yay -S --needed --noconfirm sddm-astronaut-theme || \
                print_warning "Could not install sddm-astronaut-theme"
        fi
        
        read -p "Do you want to update SDDM config? This requires sudo. (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo cp "$DOTFILES_DIR/sddm/sddm.conf" /etc/sddm.conf
            print_success "SDDM configuration updated"
        else
            print_warning "Skipped SDDM configuration"
        fi
    fi
}

# Enable necessary services
setup_bin
    enable_services() {
    print_header "Enabling Services"
    
    # NetworkManager
    if systemctl is-enabled NetworkManager &> /dev/null; then
        print_success "NetworkManager already enabled"
    else
        sudo systemctl enable NetworkManager
        print_success "Enabled NetworkManager"
    fi
    
    # Bluetooth
    if systemctl is-enabled bluetooth &> /dev/null; then
        print_success "Bluetooth already enabled"
    else
        sudo systemctl enable bluetooth
        print_success "Enabled Bluetooth"
    fi
    
    # SDDM
    if systemctl is-enabled sddm &> /dev/null; then
        print_success "SDDM already enabled"
    else
        sudo systemctl enable sddm
        print_success "Enabled SDDM"
    fi
    
    # OpenRazer (user service)
    if systemctl --user is-enabled openrazer-daemon &> /dev/null; then
        print_success "OpenRazer daemon already enabled"
    else
        systemctl --user enable openrazer-daemon
        print_success "Enabled OpenRazer daemon (user)"
    fi
}

# Post-installation notes
post_install_notes() {
    print_header "Post-Installation Notes"
    
    echo -e "${YELLOW}Recommended next steps:${NC}"
    echo ""
    echo "1. Log out and log back in for group changes (plugdev) to take effect"
    echo "2. Reboot your system to apply GRUB and SDDM themes"
    echo ""
    
    # Ask to run post-install.fish
    if [ -f "$DOTFILES_DIR/post-install.fish" ]; then
        echo ""
        read -p "Would you like to run the post-install script for additional customizations? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Running post-install.fish..."
            fish "$DOTFILES_DIR/post-install.fish" --skip-grub --skip-sddm
        else
            echo ""
            echo -e "${BLUE}You can run it later with:${NC}"
            echo "  ./post-install.fish --skip-grub --skip-sddm"
        fi
    fi
    
    echo ""
    print_success "Installation complete! Please reboot your system."
}

# Main installation flow
# Setup wallpapers
setup_wallpapers() {
    print_header "Setting up Wallpapers"
    
    WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
    mkdir -p "$WALLPAPER_DIR"
    
    if [ -d "$DOTFILES_DIR/wallpapers" ]; then
        cp "$DOTFILES_DIR/wallpapers/"* "$WALLPAPER_DIR/" 2>/dev/null
        print_success "Copied 25 wallpapers to $WALLPAPER_DIR"
        print_info "Use caelestia wallpaper command to set wallpaper"
    fi
}
# Setup custom scripts
setup_bin() {
    print_header "Setting Up Custom Scripts"
    
    mkdir -p ~/.local/bin
    cp -r "$DOTFILES_DIR/bin/"* ~/.local/bin/
    chmod +x ~/.local/bin/*
    
    print_success "Custom scripts installed to ~/.local/bin/"
}
main() {
    print_header "Dotfiles Installation"
    echo "This script will install and configure:"
    echo "  - Arch Linux packages (84 packages)"
    echo "  - Hyprland + Caelestia desktop"
    echo "  - Fish shell with aliases"
    echo "  - Foot terminal, Fuzzel launcher"
    echo "  - Spicetify for Spotify theming"
    echo "  - btop, cava, fastfetch"
    echo "  - OpenRazer + Polychromatic"
    echo "  - GTK and cursor themes"
    echo "  - VS Code settings"
    echo "  - GRUB and SDDM themes"
    echo ""
    
    read -p "Do you want to continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installation cancelled"
        exit 0
    fi
    
    check_not_root
    enable_multilib
    install_yay
    install_packages
    install_caelestia
    setup_caelestia_configs
    setup_hyprland
    setup_fish
    setup_foot
    setup_fuzzel
    setup_vscode
    setup_spicetify
    setup_btop
    setup_cava
    setup_fastfetch
    setup_openrazer
    setup_polychromatic
    setup_gtk
    setup_cursor
    setup_grub
    setup_sddm
    setup_bin
    enable_services
    setup_wallpapers
    post_install_notes
    print_summary
}

# Run main function
main "$@"


