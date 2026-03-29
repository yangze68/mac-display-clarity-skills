#!/usr/bin/env bash
set -euo pipefail

DISPLAY_NAME=""

usage() {
  cat <<'EOF'
Usage:
  collect-display-state.sh [--display-name "LG SDQHD"]

Purpose:
  Print the macOS display state that matters for HiDPI-like clarity work:
  - system_profiler display summary
  - ioreg display metadata
  - custom override files
  - DisplayResolutionEnabled
  - windowserver display plist snippets
EOF
}

section() {
  printf '\n== %s ==\n' "$1"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --display-name)
      [[ $# -ge 2 ]] || {
        echo "Missing value for --display-name" >&2
        exit 1
      }
      DISPLAY_NAME="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

section "Time"
date

section "Display Summary"
system_profiler SPDisplaysDataType

section "IORegistry Display Metadata"
if [[ -n "$DISPLAY_NAME" ]]; then
  ioreg -lw0 | grep -nE "${DISPLAY_NAME}|ProductName|device name|EDID UUID|LegacyManufacturerID|NativeFormatHorizontalPixels|NativeFormatVerticalPixels|ManufacturerName|WeekOfManufacture|YearOfManufacture" | sed -n '1,220p' || true
else
  ioreg -lw0 | grep -nE 'ProductName|device name|EDID UUID|LegacyManufacturerID|NativeFormatHorizontalPixels|NativeFormatVerticalPixels|ManufacturerName|WeekOfManufacture|YearOfManufacture' | sed -n '1,220p' || true
fi

section "Custom Override Files"
find /Library/Displays/Contents/Resources/Overrides -type f 2>/dev/null | sort || true

section "DisplayResolutionEnabled"
if [[ -f /Library/Preferences/com.apple.windowserver.plist ]]; then
  plutil -extract DisplayResolutionEnabled raw -o - /Library/Preferences/com.apple.windowserver.plist 2>/dev/null || echo "not set"
else
  echo "windowserver plist not found"
fi

section "System windowserver.displays Snippet"
if [[ -f /Library/Preferences/com.apple.windowserver.displays.plist ]]; then
  plutil -convert xml1 -o - /Library/Preferences/com.apple.windowserver.displays.plist | grep -nE 'UUID|Wide|High|Scale|Hz|Depth|DisplayUUIDMappings_v3' | sed -n '1,260p' || true
else
  echo "system display plist not found"
fi

section "User ByHost windowserver.displays Files"
find "${HOME}/Library/Preferences/ByHost" -maxdepth 1 -name 'com.apple.windowserver.displays*.plist' | sort || true

for plist in "${HOME}"/Library/Preferences/ByHost/com.apple.windowserver.displays*.plist; do
  [[ -f "$plist" ]] || continue
  echo "-- ${plist}"
  plutil -convert xml1 -o - "$plist" | grep -nE 'UUID|Wide|High|Scale|Hz|Depth|DisplayUUIDMappings_v3' | sed -n '1,220p' || true
done
