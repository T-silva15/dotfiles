#!/bin/bash
# Toggle clean mode: disable animations, blur, shadows, and live wallpaper
# Usage: clean-mode.sh [on|off|toggle]

STATE_FILE="/tmp/clean-mode-active"
SAVED_WALLPAPER="/tmp/clean-mode-saved-wallpaper"
SAVED_SCHEME="/tmp/clean-mode-saved-scheme"
CLEAN_SCHEME="onedark"

enable_interview_mode() {
    # Save current wallpaper path for restoration
    local current_wp
    current_wp=$(readlink -f ~/.config/caelestia/wallpaper 2>/dev/null || echo "")
    [ -n "$current_wp" ] && echo "$current_wp" > "$SAVED_WALLPAPER"

    # Save current scheme for restoration
    local scheme_info
    scheme_info=$(caelestia scheme get 2>/dev/null)
    {
        echo "$scheme_info" | grep 'Name:' | awk '{print $2}'
        echo "$scheme_info" | grep 'Flavour:' | awk '{print $2}'
        echo "$scheme_info" | grep 'Mode:' | awk '{print $2}'
        echo "$scheme_info" | grep 'Variant:' | awk '{print $2}'
    } > "$SAVED_SCHEME"

    # Disable Hyprland animations
    hyprctl keyword animations:enabled false

    # Disable blur
    hyprctl keyword decoration:blur:enabled false

    # Disable shadows
    hyprctl keyword decoration:shadow:enabled false

    # Reduce gaps for cleaner look
    hyprctl keyword general:gaps_out 5
    hyprctl keyword general:gaps_in 3

    # Disable window opacity (make fully opaque)
    hyprctl keyword decoration:active_opacity 1.0
    hyprctl keyword decoration:inactive_opacity 1.0

    # Stop live wallpaper
    pkill -f "linux-wallpaperengine" 2>/dev/null

    # Set clean wallpaper
    pkill swaybg 2>/dev/null
    swaybg -i "$HOME/Pictures/arch-clean.png" -m fill &>/dev/null &
    disown

    # Set clean color scheme for sidebar/shell
    caelestia scheme set -n "$CLEAN_SCHEME" -m dark &>/dev/null

    touch "$STATE_FILE"
    echo "Clean mode ON — animations, blur, shadows, and live wallpaper disabled"
}

disable_interview_mode() {
    # Re-enable animations
    hyprctl keyword animations:enabled true

    # Re-enable blur
    hyprctl keyword decoration:blur:enabled true

    # Re-enable shadows
    hyprctl keyword decoration:shadow:enabled true

    # Restore gaps
    hyprctl keyword general:gaps_out 40
    hyprctl keyword general:gaps_in 10

    # Restore window opacity
    hyprctl keyword decoration:active_opacity 0.95
    hyprctl keyword decoration:inactive_opacity 0.95

    # Restore saved color scheme
    if [ -f "$SAVED_SCHEME" ]; then
        local saved_name saved_flavour saved_mode saved_variant
        saved_name=$(sed -n '1p' "$SAVED_SCHEME")
        saved_flavour=$(sed -n '2p' "$SAVED_SCHEME")
        saved_mode=$(sed -n '3p' "$SAVED_SCHEME")
        saved_variant=$(sed -n '4p' "$SAVED_SCHEME")
        local scheme_args=()
        [ -n "$saved_name" ] && scheme_args+=(-n "$saved_name")
        [ -n "$saved_flavour" ] && scheme_args+=(-f "$saved_flavour")
        [ -n "$saved_mode" ] && scheme_args+=(-m "$saved_mode")
        [ -n "$saved_variant" ] && scheme_args+=(-v "$saved_variant")
        caelestia scheme set "${scheme_args[@]}" &>/dev/null
        rm -f "$SAVED_SCHEME"
    fi

    # Stop swaybg and restore previous wallpaper + colors
    pkill swaybg 2>/dev/null
    if [ -f "$SAVED_WALLPAPER" ]; then
        local prev_wp
        prev_wp=$(cat "$SAVED_WALLPAPER")
        caelestia wallpaper -f "$prev_wp" &>/dev/null
        rm -f "$SAVED_WALLPAPER"
    fi
    ~/.config/scripts/set-wallpaper-engine.sh --random &>/dev/null &

    rm -f "$STATE_FILE"
    echo "Clean mode OFF — animations and live wallpaper restored"
}

is_active() {
    [ -f "$STATE_FILE" ]
}

case "${1:-toggle}" in
    on)
        enable_interview_mode
        ;;
    off)
        disable_interview_mode
        ;;
    toggle)
        if is_active; then
            disable_interview_mode
        else
            enable_interview_mode
        fi
        ;;
    status)
        if is_active; then
            echo "Clean mode is ON"
        else
            echo "Clean mode is OFF"
        fi
        ;;
    *)
        echo "Usage: $(basename "$0") [on|off|toggle|status]"
        exit 1
        ;;
esac
