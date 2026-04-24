#!/usr/bin/env python3
"""
One-shot Razer mouse battery notifier.
Sends a single notification when battery drops to/below 15%.
Resets when battery rises above 15% (e.g., after charging).
State is tracked via a flag file in /tmp.
"""

import sys
import subprocess
from pathlib import Path

THRESHOLD = 15
FLAG_FILE = Path("/tmp/razer-battery-notified")


def get_battery() -> int | None:
    try:
        import openrazer.client
        dm = openrazer.client.DeviceManager()
        for device in dm.devices:
            if hasattr(device, "battery_level"):
                level = device.battery_level
                if level is not None and level >= 0:
                    return int(level)
    except Exception:
        pass
    return None


def notify(level: int) -> None:
    subprocess.run([
        "notify-send",
        "--urgency=critical",
        "--icon=battery-caution",
        "--app-name=Razer Mouse",
        "Low Battery",
        f"Razer Viper V2 Pro battery is at {level}%. Please charge.",
    ], check=False)


def main() -> None:
    level = get_battery()
    if level is None:
        sys.exit(0)

    if level > THRESHOLD:
        # Battery recovered above threshold — reset so we can notify again next time
        FLAG_FILE.unlink(missing_ok=True)
        sys.exit(0)

    # Battery is at or below threshold
    if FLAG_FILE.exists():
        # Already notified for this low-battery session
        sys.exit(0)

    # First time hitting the threshold — notify once and set flag
    notify(level)
    FLAG_FILE.touch()


if __name__ == "__main__":
    main()
