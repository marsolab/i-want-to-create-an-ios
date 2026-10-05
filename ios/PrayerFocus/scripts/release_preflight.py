#!/usr/bin/env python3
"""Inspect a built app. Structural validation is separate from distribution evidence."""
import argparse
import json
import plistlib
import subprocess
import sys
from pathlib import Path
from urllib.parse import urlparse

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("app", type=Path)
parser.add_argument("--structural-only", action="store_true", help="Unsigned artifact checks; never confirms release readiness.")
parser.add_argument("--team-id", default="")
args = parser.parse_args()
errors = []

def check(condition, message):
    if not condition:
        errors.append(message)

def plist(path):
    try:
        return plistlib.loads(path.read_bytes())
    except (OSError, ValueError, plistlib.InvalidFileException):
        errors.append(f"Missing or invalid plist: {path}")
        return {}

info = plist(args.app / "Info.plist")
check(info.get("CFBundleDisplayName") == "SalahSide", "App display name must be SalahSide.")
check(info.get("CFBundleIdentifier") == "com.marsolab.PrayerFocus", "Unexpected app identity.")
check(info.get("ITSAppUsesNonExemptEncryption") is False, "Encryption export declaration missing.")
check(bool(info.get("CFBundleIcons")), "Compiled app icon missing.")
check((args.app / "ThirdPartyNotices.txt").is_file(), "Bundled calculation library license missing.")
check(not list(args.app.rglob("*.storekit")), "Local StoreKit test fixture was bundled in the release app.")
expected = {
    "com.marsolab.PrayerFocus.Widgets": "com.apple.widgetkit-extension",
    "com.marsolab.PrayerFocus.Monitor": "com.apple.deviceactivity.monitor-extension",
    "com.marsolab.PrayerFocus.ShieldAction": "com.apple.ManagedSettings.shield-action-service",
    "com.marsolab.PrayerFocus.Shield": "com.apple.ManagedSettingsUI.shield-configuration-service",
}
seen = set()
bundles = [args.app]
for extension in (args.app / "PlugIns").glob("*.appex"):
    bundles.append(extension)
    metadata = plist(extension / "Info.plist")
    identity = metadata.get("CFBundleIdentifier")
    seen.add(identity)
    check(metadata.get("NSExtension", {}).get("NSExtensionPointIdentifier") == expected.get(identity), f"Unexpected extension point for {identity}.")
    for key in ["CFBundleVersion", "CFBundleShortVersionString"]:
        check(bool(info.get(key)) and metadata.get(key) == info.get(key), f"Version mismatch in {identity}: {key}.")
check(seen == set(expected), "App must embed the widget, Device Activity monitor, shield configuration and shield action extensions.")
for bundle in bundles:
    privacy = plist(bundle / "PrivacyInfo.xcprivacy")
    check(privacy.get("NSPrivacyTracking") is False, f"Tracking declaration missing in {bundle.name}.")
    reasons = {reason for api in privacy.get("NSPrivacyAccessedAPITypes", [])
        if api.get("NSPrivacyAccessedAPIType") == "NSPrivacyAccessedAPICategoryUserDefaults"
        for reason in api.get("NSPrivacyAccessedAPITypeReasons", [])}
    if "ShieldAction" not in bundle.name:
        check("CA92.1" in reasons and "1C8F.1" in reasons, f"UserDefaults privacy reasons missing in {bundle.name}.")

if not args.structural_only:
    policy = urlparse(info.get("SalahSidePrivacyPolicyURL", ""))
    check(policy.scheme == "https" and bool(policy.hostname) and "$" not in policy.geturl(), "Published HTTPS privacy policy URL must be configured.")
    check(bool(args.team_id), "Apple Developer Team ID is required.")
    check("iPhoneOS" in info.get("CFBundleSupportedPlatforms", []), "Distribution requires an iPhoneOS archive.")
    for bundle in bundles:
        verification = subprocess.run(["codesign", "--verify", "--strict", str(bundle)], capture_output=True, text=True)
        check(verification.returncode == 0, f"Invalid or missing code signature: {bundle.name}.")
        result = subprocess.run(["codesign", "-d", "--entitlements", ":-", str(bundle)], capture_output=True)
        try:
            entitlements = plistlib.loads(result.stdout)
        except (ValueError, plistlib.InvalidFileException):
            entitlements = {}
        check(entitlements.get("com.apple.developer.team-identifier") == args.team_id and bool(args.team_id), f"Signing team missing/mismatched: {bundle.name}.")
        check(entitlements.get("get-task-allow") is not True, f"Development signature cannot be distributed: {bundle.name}.")
        if "Widgets" not in bundle.name:
            check(entitlements.get("com.apple.developer.family-controls") is True, f"Family Controls entitlement missing: {bundle.name}.")
        if "ShieldAction" not in bundle.name:
            check("group.com.marsolab.PrayerFocus" in entitlements.get("com.apple.security.application-groups", []), f"App Group missing: {bundle.name}.")

print(json.dumps({"mode": "structural" if args.structural_only else "distribution-artifact",
    "passed": not errors, "errors": errors,
    "note": "This does not verify App Store Connect products, published policy content, Apple entitlement approval, sandbox billing or physical-device behavior."}, indent=2))
sys.exit(1 if errors else 0)
