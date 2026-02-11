#!/usr/bin/env python3
"""
Wrapper for 'caelestia wallpaper' that fixes the materialyoucolor v2.0.10 API bug.
Bug: MaterialDynamicColors.all_colors was removed in newer versions.
This monkey-patches gen_scheme() at runtime before calling caelestia.

Usage: python3 caelestia-wallpaper-fix.py -f /path/to/image.jpg
"""
import sys

# Monkey-patch gen_scheme before caelestia imports it
from materialyoucolor.dynamiccolor.dynamic_color import DynamicColor
from materialyoucolor.dynamiccolor.material_dynamic_colors import MaterialDynamicColors

# Add a shim for all_colors if missing
if not hasattr(MaterialDynamicColors, 'all_colors'):
    @property
    def _all_colors(self):
        """Shim: iterate DynamicColor attributes to replace removed all_colors."""
        colors = []
        for attr_name in dir(type(self)):
            if attr_name.startswith('_') or attr_name == 'all_colors':
                continue
            attr = getattr(self, attr_name)
            if isinstance(attr, DynamicColor):
                # Use the attribute name (camelCase) as the name, matching old behavior
                if not hasattr(attr, '_orig_name'):
                    attr._orig_name = attr.name
                    attr.name = attr_name
                colors.append(attr)
        return colors

    MaterialDynamicColors.all_colors = _all_colors

# Now run caelestia normally
from caelestia import main
sys.exit(main())
