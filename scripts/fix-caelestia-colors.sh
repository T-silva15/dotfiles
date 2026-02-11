#!/bin/bash
# Fix for Caelestia color extraction crash with materialyoucolor v2.0.10+
# Bug: MaterialDynamicColors.all_colors attribute was removed in newer versions
# This patches /usr/lib/python3.14/site-packages/caelestia/utils/material/generator.py
#
# Run: sudo bash ~/dotfiles/scripts/fix-caelestia-colors.sh
# Re-run after every caelestia-cli package update

set -euo pipefail

TARGET="/usr/lib/python3.14/site-packages/caelestia/utils/material/generator.py"

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use: sudo bash $0"
    exit 1
fi

if ! [ -f "$TARGET" ]; then
    echo "Error: $TARGET not found"
    exit 1
fi

if ! grep -q 'all_colors' "$TARGET"; then
    echo "Already patched (no 'all_colors' reference found). No action needed."
    exit 0
fi

echo "Backing up $TARGET → ${TARGET}.bak"
cp "$TARGET" "${TARGET}.bak"

echo "Patching..."
python3 << 'PYEOF'
target = "/usr/lib/python3.14/site-packages/caelestia/utils/material/generator.py"

with open(target, "r") as f:
    content = f.read()

# 1. Add DynamicColor import
old_import = "from materialyoucolor.dynamiccolor.material_dynamic_colors import ("
new_import = "from materialyoucolor.dynamiccolor.dynamic_color import DynamicColor\nfrom materialyoucolor.dynamiccolor.material_dynamic_colors import ("
content = content.replace(old_import, new_import, 1)

# 2. Replace broken all_colors iteration with dir() inspection
old_loop = "    for colour in dyn_colours.all_colors:\n        colours[colour.name] = colour.get_hct(primary_scheme)"
new_loop = """    for attr_name in dir(dyn_colours):
        if attr_name.startswith('_'):
            continue
        attr = getattr(dyn_colours, attr_name)
        if isinstance(attr, DynamicColor):
            colours[attr_name] = attr.get_hct(primary_scheme)"""
content = content.replace(old_loop, new_loop, 1)

with open(target, "w") as f:
    f.write(content)

print("File patched successfully.")
PYEOF

# Verify
if python3 -c "from caelestia.utils.material.generator import gen_scheme; print('Import OK')" 2>/dev/null; then
    echo "SUCCESS: Patch verified — gen_scheme imports correctly."
else
    echo "FAILED: Restoring backup..."
    cp "${TARGET}.bak" "$TARGET"
    exit 1
fi
