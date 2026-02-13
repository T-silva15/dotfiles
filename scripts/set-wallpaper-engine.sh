#!/bin/bash
# Set a Wallpaper Engine wallpaper and sync Caelestia colors
# Usage: set-wallpaper-engine.sh [wallpaper_id] [--list] [--monitor MONITOR] [--stop]

WORKSHOP_DIR="$HOME/.steam/steam/steamapps/workshop/content/431960"
DEFAULT_MONITOR="HDMI-A-1"
FPS=30

list_wallpapers() {
    echo "Available Wallpaper Engine wallpapers:"
    echo "======================================="
    for dir in "$WORKSHOP_DIR"/*/; do
        local id=$(basename "$dir")
        local name=$(jq -r '.title // "unknown"' "$dir/project.json" 2>/dev/null)
        local type=$(jq -r '.type // "unknown"' "$dir/project.json" 2>/dev/null)
        printf "  %-12s %-8s %s\n" "$id" "[$type]" "$name"
    done
}

get_preview_image() {
    local wp_dir="$1"
    local wp_id="$2"

    for ext in jpg jpeg png webp; do
        [ -f "$wp_dir/preview.$ext" ] && echo "$wp_dir/preview.$ext" && return 0
    done

    # Convert GIF preview to static image
    if [ -f "$wp_dir/preview.gif" ]; then
        local tmp="/tmp/wp-preview-$wp_id.jpg"
        ffmpeg -i "$wp_dir/preview.gif" -frames:v 1 -y "$tmp" 2>/dev/null
        [ -f "$tmp" ] && echo "$tmp" && return 0
    fi

    return 1
}

sync_colors() {
    local preview="$1"
    if [ -z "$preview" ]; then
        echo "Warning: No preview found, colors not synced"
        return 1
    fi

    echo "Syncing Caelestia colors from preview..."
    # Use the monkey-patched wrapper to work around materialyoucolor v2.0.10 bug
    # (MaterialDynamicColors.all_colors was removed)
    local SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    python3 "$SCRIPT_DIR/caelestia-wallpaper-fix.py" wallpaper -f "$preview" 2>/dev/null
    echo "Colors synced!"
}

stop_wallpaper() {
    pkill -f "linux-wallpaperengine" 2>/dev/null
    sleep 0.3
    echo "Wallpaper engine stopped"
}

set_wallpaper() {
    local wp_id="$1"
    local monitor="${2:-$DEFAULT_MONITOR}"
    local wp_dir="$WORKSHOP_DIR/$wp_id"

    if [ ! -d "$wp_dir" ]; then
        echo "Error: Wallpaper ID $wp_id not found"
        echo "Use --list to see available wallpapers"
        exit 1
    fi

    local name=$(jq -r '.title // "unknown"' "$wp_dir/project.json" 2>/dev/null)
    echo "Setting wallpaper: $name ($wp_id)"

    # Kill any existing instances
    stop_wallpaper

    # Step 1: Sync Caelestia colors from preview image
    local preview
    preview=$(get_preview_image "$wp_dir" "$wp_id")
    sync_colors "$preview"

    # Step 2: Launch animated wallpaper via wlr-layer-shell (renders on top)
    echo "Starting animated wallpaper on all monitors..."
    linux-wallpaperengine \
        --screen-root eDP-1 --scaling fill \
        --screen-root HDMI-A-1 --scaling fill \
        --silent \
        --fps "$FPS" \
        --no-fullscreen-pause \
        "$wp_id" &>/dev/null &
    disown

    echo "Done! Wallpaper '$name' is now active on all monitors."
}

random_wallpaper() {
    local ids=()
    for dir in "$WORKSHOP_DIR"/*/; do
        ids+=($(basename "$dir"))
    done

    if [ ${#ids[@]} -eq 0 ]; then
        echo "Error: No wallpapers found"
        exit 1
    fi

    local random_id=${ids[$RANDOM % ${#ids[@]}]}
    set_wallpaper "$random_id"
}

fuzzel_picker() {
    local entries=""
    for dir in "$WORKSHOP_DIR"/*/; do
        local id=$(basename "$dir")
        local name=$(jq -r '.title // "unknown"' "$dir/project.json" 2>/dev/null)
        local type=$(jq -r '.type // "unknown"' "$dir/project.json" 2>/dev/null)
        entries+="$name ($id) [$type]\n"
    done
    entries+="Stop Live Wallpaper\n"

    local choice
    choice=$(printf "%b" "$entries" | fuzzel -d -p "Live Wallpaper: " -w 50 -l 15)
    [ -z "$choice" ] && exit 0

    if [ "$choice" = "Stop Live Wallpaper" ]; then
        stop_wallpaper
        exit 0
    fi

    # Extract ID from "Name (ID) [type]"
    local wp_id
    wp_id=$(echo "$choice" | grep -oP '\(\K[0-9]+(?=\))')
    if [ -z "$wp_id" ]; then
        exit 1
    fi

    set_wallpaper "$wp_id"
}

# Parse arguments
case "${1:-}" in
    --random|-r)
        random_wallpaper
        ;;
    --fuzzel|-f)
        fuzzel_picker
        ;;
    --list|-l)
        list_wallpapers
        ;;
    --stop|-s)
        stop_wallpaper
        ;;
    --help|-h)
        echo "Usage: $(basename "$0") WALLPAPER_ID [--monitor MONITOR]"
        echo "       $(basename "$0") --list"
        echo "       $(basename "$0") --fuzzel"
        echo "       $(basename "$0") --random"
        echo "       $(basename "$0") --stop"
        echo ""
        echo "Set a Wallpaper Engine animated wallpaper and sync Caelestia colors."
        echo ""
        echo "Options:"
        echo "  WALLPAPER_ID       Steam Workshop ID of the wallpaper"
        echo "  --list, -l         List available wallpapers"
        echo "  --fuzzel, -f       Open Fuzzel picker for wallpaper selection"
        echo "  --random, -r       Set a random wallpaper"
        echo "  --stop, -s         Stop the current animated wallpaper"
        echo "  --help, -h         Show this help"
        ;;
    "")
        echo "Error: No wallpaper ID specified"
        echo "Use --list to see available wallpapers, or --help for usage"
        exit 1
        ;;
    *)
        monitor="$DEFAULT_MONITOR"
        if [ "${2:-}" = "--monitor" ] || [ "${2:-}" = "-m" ]; then
            monitor="$3"
        fi
        set_wallpaper "$1" "$monitor"
        ;;
esac
