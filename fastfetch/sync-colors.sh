#!/bin/bash
# Generates fastfetch config with Caelestia's current color scheme

SCHEME_FILE="$HOME/.local/state/caelestia/scheme.json"
FF_CONFIG="$HOME/.config/fastfetch/config.jsonc"
TUX_FILE="$HOME/.config/fastfetch/tux.txt"

if [[ ! -f "$SCHEME_FILE" ]]; then
    exit 1
fi

# Extract colors from Caelestia scheme
PRIMARY=$(cat "$SCHEME_FILE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['colours']['primary'])")
TERTIARY=$(cat "$SCHEME_FILE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['colours']['tertiary_paletteKeyColor'])")

# Generate fastfetch config with dynamic colors
cat > "$FF_CONFIG" << EOF
{
    "\$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": {
        "type": "file",
        "source": "$TUX_FILE",
        "color": {
            "1": "#$PRIMARY"
        }
    },
    "display": {
        "separator": "  ",
        "color": {
            "keys": "#$TERTIARY",
            "title": "#$PRIMARY"
        }
    },
    "modules": [
        {
            "type": "title",
            "format": "{user-name}@{host-name}"
        },
        {
            "type": "separator"
        },
        {
            "type": "os",
            "key": "OS"
        },
        {
            "type": "kernel",
            "key": "Kernel"
        },
        {
            "type": "uptime",
            "key": "Uptime"
        },
        {
            "type": "packages",
            "key": "Packages"
        },
        {
            "type": "shell",
            "key": "Shell"
        },
        {
            "type": "wm",
            "key": "WM"
        },
        {
            "type": "terminal",
            "key": "Terminal"
        },
        {
            "type": "cpu",
            "key": "CPU"
        },
        {
            "type": "gpu",
            "key": "GPU"
        },
        {
            "type": "memory",
            "key": "Memory"
        },
        {
            "type": "separator"
        },
        {
            "type": "colors",
            "symbol": "circle"
        }
    ]
}
EOF
