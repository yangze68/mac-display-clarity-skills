# Playbook

## Goal

Improve the *appearance* of sharpness on a macOS external display.

This is not true panel resolution conversion. Phrase the outcome as:

- clearer
- crisper
- smoother
- HiDPI-like

## Three-Layer Model

Treat every case as three aligned layers:

1. Display override  
   Example path: `/Library/Displays/Contents/Resources/Overrides/...`

2. Global WindowServer gate  
   File: `/Library/Preferences/com.apple.windowserver.plist`  
   Key: `DisplayResolutionEnabled=true`

3. Active mode state  
   Files:
   - `/Library/Preferences/com.apple.windowserver.displays.plist`
   - `~/Library/Preferences/ByHost/com.apple.windowserver.displays.*.plist`

Most failed attempts only change layer 1.

## Safe Workflow

1. Collect evidence before edits.
   - Run `scripts/collect-display-state.sh`
   - Record the target display name
   - Record vendor/product identifiers if available
   - Record native resolution and current apparent resolution

2. Try native macOS scaled modes first.
   - Open Display Settings
   - Show all resolutions
   - If the desired result is already available, do not patch files

3. Back up before any system changes.
   Files that usually matter:
   - `/Library/Displays/Contents/Resources/Overrides/...`
   - `/Library/Preferences/com.apple.windowserver.plist`
   - `/Library/Preferences/com.apple.windowserver.displays.plist`
   - `~/Library/Preferences/ByHost/com.apple.windowserver.displays.*.plist`

4. Install or verify the display override.
   - This creates the candidate scaled modes
   - It does not guarantee the current mode is active

5. Enable `DisplayResolutionEnabled`.
   - Without it, many custom or hidden modes stay unavailable

6. Inspect `windowserver.displays`.
   - Look for the target display UUID
   - Compare `Wide`, `High`, `Scale`, `Hz`, and `Depth`
   - For successful BetterDisplay-like reproductions, this layer often contains the real “current mode” that makes the display actually look sharper

7. Reconnect the display or reboot.
   - Collect evidence again
   - Compare before vs after

## How To Think About UUIDs

- Display override files are matched by vendor/product identifiers
- `windowserver.displays` state is matched by display UUIDs
- Those UUIDs can differ across Macs

Never copy another machine's display UUID blindly.

## Failure Pattern To Watch For

If the override is present and `DisplayResolutionEnabled=true`, but the display still looks unchanged, the missing piece is usually the active mode inside `windowserver.displays`.

That is the exact failure pattern seen in the LG SDQHD case that inspired this skill.

## Validation Signs

Good signs:

- `system_profiler SPDisplaysDataType` shows the target display with a changed apparent mode
- Display Settings exposes the expected scaled choices
- `windowserver.displays` includes the expected `Wide`, `High`, and `Scale` values for the correct display UUID

Bad signs:

- only the override changed
- no display UUID can be mapped confidently
- the display name or vendor/product identifiers do not match the intended monitor
