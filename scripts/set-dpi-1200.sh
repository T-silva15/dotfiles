#!/bin/bash
# Set Razer Viper V2 Pro mouse DPI to 1200
# Uses OpenRazer Python API (polychromatic-cli is deprecated)
python3 -c "
from openrazer.client import DeviceManager
dm = DeviceManager()
for d in dm.devices:
    if d.type == 'mouse':
        d.dpi = (1200, 1200)
        print(f'{d.name} DPI set to 1200')
" 2>/dev/null || echo "No Razer mouse detected. Is the dongle plugged in?"
