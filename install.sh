#!/bin/bash

# ============================================================================
# Dotfiles Installation Script
# Arch Linux + Hyprland + Caelestia Setup
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
        exit 1
    fi

    # Extract package names (first column)
    packages=$(cut -d' ' -f1 "$DOTFILES_DIR/packages.txt")
    
    # Separate official and AUR packages
    official_packages=""
    aur_packages=""
    
    for pkg in $packages; do
        if pacman -Si "$pkg" &> /dev/null; then
            official_packages="$official_packages $pkg"
        else
            aur_packages="$aur_packages $pkg"
        fi
    done

    # Install official packages
    if [ -n "$official_packages" ]; then
        print_info "Installing official packages..."
        sudo pacman -S --needed --noconfirm $official_packages || true
    fi

    # Install AUR packages
    if [ -n "$aur_packages" ]; then
        print_info "Installing AUR packages..."
        yay -S --needed --noconfirm $aur_packages || true
    fi

    print_success "Packages installed"
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

# Setup VS Code settings
setup_vscode() {
    print_header "Setting up VS Code"
    
    VSCODE_CONFIG_DIR="$HOME/.config/Code/User"
    mkdir -p "$VSCODE_CONFIG_DIR"
    
    if [ -f "$DOTFILES_DIR/vscode/settings.json" ]; then
        cp "$DOTFILES_DIR/vscode/settings.json" "$VSCODE_CONFIG_DIR/"
        print_success "Copied VS Code settings"
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
        print_info "Installing Tartarus GRUB theme..."
        
        # Check if tartarus theme exists, if not try to install
        if [ ! -d "/usr/share/grub/themes/tartarus" ]; then
            print_warning "Tartarus theme not found. Please install it manually."
            print_info "You can find it at: https://github.com/AllJavi/tartarus-grub"
        fi
        
        read -p "Do you want to update GRUB config? This requires sudo. (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo cp "$DOTFILES_DIR/grub/grub" /etc/default/grub
            sudo grub-mkconfig -o /boot/grub/grub.cfg
            print_success "GRUB configuration updated"
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
    
    echo -e "${YELLOW}Things you may need to do manually:${NC}"
    echo ""
    echo "1. Install Tartarus GRUB theme:"
    echo "   git clone https://github.com/AllJavi/tartarus-grub.git"
    echo "   cd tartarus-grub && sudo ./install.sh"
    echo ""
    echo "2. Add user to openrazer group (for Razer peripherals):"
    echo "   sudo gpasswd -a \$USER plugdev"
    echo ""
    echo "3. Log out and log back in for group changes to take effect"
    echo ""
    echo "4. Install VS Code Caelestia theme from marketplace"
    echo ""
    echo "5. Configure Spicetify for Spotify theming:"
    echo "   spicetify backup apply"
    echo ""
    print_success "Installation complete! Please reboot your system."
}

# Main installation flow
main() {
    print_header "Dotfiles Installation"
    echo "This script will install and configure:"
    echo "  - Arch Linux packages"
    echo "  - Hyprland + Caelestia desktop"
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
    install_yay
    install_packages
    install_caelestia
    setup_caelestia_configs
    setup_vscode
    setup_gtk
    setup_cursor
    setup_grub
    setup_sddm
    enable_services
    post_install_notes
}

# Run main function
main "$@"
