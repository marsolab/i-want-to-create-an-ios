#!/usr/bin/env python3
"""Select an installed, available iPhone for unsigned local/CI tests."""
import json
import re
import subprocess

payload = json.loads(subprocess.check_output(["xcrun", "simctl", "list", "devices", "available", "--json"]))
candidates = [(tuple(map(int, re.findall(r"\d+", runtime))), device["name"], device["udid"])
    for runtime, devices in payload["devices"].items() if "iOS" in runtime
    for device in devices if device.get("isAvailable") and device["name"].startswith("iPhone")]
if not candidates:
    raise SystemExit("No available iPhone simulator. Install an iOS runtime in Xcode.")
print(max(candidates)[2])
