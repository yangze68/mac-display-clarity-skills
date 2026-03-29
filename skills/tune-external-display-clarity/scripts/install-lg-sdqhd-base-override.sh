#!/usr/bin/env bash
set -euo pipefail

readonly DISPLAY_NAME="LG SDQHD"
readonly VENDOR_ID_HEX="1e6d"
readonly PRODUCT_ID_HEX="5bf6"
readonly OVERRIDE_RELATIVE="Library/Displays/Contents/Resources/Overrides/DisplayVendorID-${VENDOR_ID_HEX}/DisplayProductID-${PRODUCT_ID_HEX}"
readonly BACKUP_SUFFIX=".backup-before-lg-sdqhd-base-override"
readonly PREFS_RELATIVE="Library/Preferences/com.apple.windowserver.plist"

usage() {
  cat <<'EOF'
Usage:
  install-lg-sdqhd-base-override.sh install [--root PATH]
  install-lg-sdqhd-base-override.sh uninstall [--root PATH]
  install-lg-sdqhd-base-override.sh status [--root PATH]
  install-lg-sdqhd-base-override.sh render

Purpose:
  Install the verified, reversible base override for LG SDQHD.
  This script writes the custom override and enables DisplayResolutionEnabled.
  It does not patch windowserver.displays to a specific UUID or active mode.
EOF
}

die() {
  echo "Error: $*" >&2
  exit 1
}

note() {
  echo "[INFO] $*"
}

override_path() {
  local root_dir="$1"
  printf '%s/%s\n' "${root_dir%/}" "$OVERRIDE_RELATIVE"
}

backup_path() {
  local root_dir="$1"
  printf '%s%s\n' "$(override_path "$root_dir")" "$BACKUP_SUFFIX"
}

prefs_path() {
  local root_dir="$1"
  printf '%s/%s\n' "${root_dir%/}" "$PREFS_RELATIVE"
}

expected_override_xml() {
  cat <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>DisplayProductID</key>
	<integer>23542</integer>
	<key>DisplayVendorID</key>
	<integer>7789</integer>
	<key>scale-resolutions</key>
	<array>
		<data>
		AAALQAAAC0A=
		</data>
		<data>
		AAAWgAAAFoA=
		</data>
		<data>
		AAAWgAAAFoAAAAAJACAAAA==
		</data>
	</array>
</dict>
</plist>
EOF
}

write_expected_override() {
  local target="$1"
  mkdir -p "$(dirname "$target")"
  expected_override_xml >"$target"
}

override_matches_expected() {
  local existing="$1"
  [[ -f "$existing" ]] || return 1

  local temp_expected
  local diff_status=0
  temp_expected="$(mktemp)"
  write_expected_override "$temp_expected"

  if ! diff -q <(plutil -convert xml1 -o - "$existing") <(plutil -convert xml1 -o - "$temp_expected") >/dev/null; then
    diff_status=1
  fi

  rm -f "$temp_expected"
  return "$diff_status"
}

enable_display_resolution() {
  local root_dir="$1"
  local prefs
  prefs="$(prefs_path "$root_dir")"

  mkdir -p "$(dirname "$prefs")"

  if [[ ! -f "$prefs" ]]; then
    cat >"$prefs" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict/>
</plist>
EOF
  fi

  if plutil -extract DisplayResolutionEnabled raw -o - "$prefs" >/dev/null 2>&1; then
    plutil -replace DisplayResolutionEnabled -bool true "$prefs"
  else
    plutil -insert DisplayResolutionEnabled -bool true "$prefs"
  fi
}

display_resolution_enabled() {
  local prefs="$1"
  local value
  [[ -f "$prefs" ]] || return 1
  value="$(plutil -extract DisplayResolutionEnabled raw -o - "$prefs" 2>/dev/null || true)"
  [[ "$value" == "1" || "$value" == "true" ]]
}

target_display_connected() {
  if ioreg -lw0 2>/dev/null | grep -Eq '"ProductName"[[:space:]]*=[[:space:]]*"LG SDQHD"|"device name"[[:space:]]*=[[:space:]]*"LG SDQHD"'; then
    return 0
  fi

  if system_profiler SPDisplaysDataType 2>/dev/null | grep -q 'LG SDQHD'; then
    return 0
  fi

  return 1
}

install_override() {
  local root_dir="$1"
  [[ "$root_dir" != "/" || "$EUID" -eq 0 ]] || die "Use sudo for system install."

  local target backup temp
  target="$(override_path "$root_dir")"
  backup="$(backup_path "$root_dir")"
  temp="$(mktemp)"

  write_expected_override "$temp"
  mkdir -p "$(dirname "$target")"

  if [[ -f "$target" && ! -f "$backup" ]]; then
    cp "$target" "$backup"
    note "Backed up existing override to $backup"
  fi

  if [[ -f "$target" ]] && override_matches_expected "$target"; then
    note "Override already matches the expected LG SDQHD base profile."
  else
    cp "$temp" "$target"
    note "Installed override at $target"
  fi

  enable_display_resolution "$root_dir"
  note "Enabled DisplayResolutionEnabled"
  rm -f "$temp"

  if [[ "$root_dir" == "/" ]]; then
    if target_display_connected; then
      note "${DISPLAY_NAME} is currently connected."
    else
      note "${DISPLAY_NAME} is not currently connected."
    fi
  fi

  cat <<'EOF'
[NEXT]
- Reconnect the display or reboot the Mac.
- Then inspect Display Settings.
- If the result is still not active, inspect windowserver.displays and patch the target display UUID manually.
EOF
}

uninstall_override() {
  local root_dir="$1"
  [[ "$root_dir" != "/" || "$EUID" -eq 0 ]] || die "Use sudo for system uninstall."

  local target backup
  target="$(override_path "$root_dir")"
  backup="$(backup_path "$root_dir")"

  if [[ -f "$backup" ]]; then
    cp "$backup" "$target"
    rm -f "$backup"
    note "Restored backup to $target"
  elif [[ -f "$target" ]]; then
    rm -f "$target"
    note "Removed override $target"
  else
    note "Nothing to uninstall"
  fi
}

show_status() {
  local root_dir="$1"
  local target prefs
  target="$(override_path "$root_dir")"
  prefs="$(prefs_path "$root_dir")"

  echo "display_name=${DISPLAY_NAME}"
  echo "override_path=${target}"
  echo "prefs_path=${prefs}"

  if [[ -f "$target" ]]; then
    echo "override_present=yes"
  else
    echo "override_present=no"
  fi

  if override_matches_expected "$target"; then
    echo "override_matches_expected=yes"
  else
    echo "override_matches_expected=no"
  fi

  if display_resolution_enabled "$prefs"; then
    echo "display_resolution_enabled=yes"
  else
    echo "display_resolution_enabled=no"
  fi

  if [[ "$root_dir" == "/" ]]; then
    if target_display_connected; then
      echo "target_display_connected=yes"
    else
      echo "target_display_connected=no"
    fi
  fi
}

main() {
  local command="${1:-}"
  local root_dir="/"

  [[ -n "$command" ]] || {
    usage
    exit 1
  }
  shift || true

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --root)
        [[ $# -ge 2 ]] || die "--root needs a value"
        root_dir="$2"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die "Unknown argument: $1"
        ;;
    esac
  done

  case "$command" in
    install)
      install_override "$root_dir"
      ;;
    uninstall)
      uninstall_override "$root_dir"
      ;;
    status)
      show_status "$root_dir"
      ;;
    render)
      expected_override_xml
      ;;
    help|-h|--help)
      usage
      ;;
    *)
      die "Unknown command: $command"
      ;;
  esac
}

main "$@"
