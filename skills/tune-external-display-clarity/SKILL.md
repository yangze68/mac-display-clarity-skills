---
name: tune-external-display-clarity
description: Use when a macOS external display looks blurry, jagged, or non-Retina, or when replicating BetterDisplay-like HiDPI-style clarity on 2K monitors after moving to another Mac. Trigger on requests involving external displays, BetterDisplay, HiDPI, display overrides, windowserver plist files, 模糊, 锯齿, 外接屏, 2K 屏更清晰, or “像高分屏一样顺滑一点”.
---

# Tune External Display Clarity

## Overview

Improve perceived sharpness on macOS external displays through scaling, display overrides, and WindowServer state.

This skill does **not** turn a 2K panel into true 4K. The goal is to reproduce a crisper, HiDPI-like appearance safely and reversibly.

## Use This Workflow

1. Collect evidence first with `scripts/collect-display-state.sh`.
2. Prefer native macOS scaled modes if the desired result is already available in Display Settings.
3. If the monitor is the known `LG SDQHD` case, use `scripts/install-lg-sdqhd-base-override.sh` to install the verified base override.
4. If the override alone does not activate the expected clarity, inspect `windowserver.displays` and patch the current mode for the target display UUID.
5. Reconnect the monitor or reboot, then collect evidence again before making new changes.

Never promise “real 4K” on a 2K panel. Describe the result as “clearer / more HiDPI-like / smoother UI scaling”.

## Decision Tree

- External display already offers a useful scaled mode in `系统设置 -> 显示器`:
  Use the native setting first. Do not patch plists unless the native choices are insufficient.
- Request is explicitly about the known `LG SDQHD` case or reproducing a previously working setup:
  Use `scripts/install-lg-sdqhd-base-override.sh` and the values in `references/lg-sdqhd-known-good.md`.
- Display is different, or the current Mac does not match the known case:
  Follow `references/playbook.md` and treat this as a new display-specific diagnosis.
- You cannot identify the target display's UUID or vendor/product information with confidence:
  Stop and report the missing evidence instead of copying another machine's identifiers.

## Quick Start

Use these commands from the skill directory:

```bash
scripts/collect-display-state.sh --display-name "LG SDQHD"
sudo scripts/install-lg-sdqhd-base-override.sh install
scripts/install-lg-sdqhd-base-override.sh status
sudo scripts/install-lg-sdqhd-base-override.sh uninstall
```

Expected follow-up after installation:

1. Disconnect and reconnect the external display, or reboot the Mac.
2. Open `系统设置 -> 显示器`.
3. Select the target monitor and inspect the available scaled resolutions.
4. If the result still does not look right, compare the current `windowserver.displays` state with the target values in `references/lg-sdqhd-known-good.md`.

## Core Model

Treat display clarity changes as a 3-layer system:

1. Display override:
   `/Library/Displays/Contents/Resources/Overrides/...`
2. Global macOS resolution gate:
   `/Library/Preferences/com.apple.windowserver.plist`
   with `DisplayResolutionEnabled=true`
3. Active WindowServer mode:
   `/Library/Preferences/com.apple.windowserver.displays.plist`
   and `~/Library/Preferences/ByHost/com.apple.windowserver.displays.*.plist`

Most failed attempts only change layer 1. Many successful BetterDisplay-like reproductions require all three layers to align.

## Known Working LG SDQHD Pattern

Read `references/lg-sdqhd-known-good.md` before patching this monitor.

The known-good case from this workspace:

- Native panel resolution: `2560x2880`
- Desired apparent mode: `1600x1800`
- Desired scale: `2`
- Refresh rate: `60Hz`

The verified base override script intentionally covers only the deterministic, reversible part:

- install override
- enable `DisplayResolutionEnabled`
- back up previous system files

If the visual result still does not match, the missing piece is usually the display UUID's active mode inside `windowserver.displays`.

## Resources

- `scripts/collect-display-state.sh`
  Gather display evidence from `system_profiler`, `ioreg`, override files, and relevant plist files before changing anything.
- `scripts/install-lg-sdqhd-base-override.sh`
  Install or remove the verified base override for `LG SDQHD`. Safe starting point for the known case.
- `references/playbook.md`
  Explain the generic diagnosis and patching workflow for external displays on macOS.
- `references/lg-sdqhd-known-good.md`
  Store the exact known-good values from this case, including the target override content and active mode fields.

## Common Mistakes

- Only copying the display override file and forgetting `windowserver.displays`.
- Copying another Mac's display UUID verbatim instead of discovering the target Mac's UUID.
- Claiming a 2K display became “real 4K”.
- Editing plist files without backups.
- Treating BetterDisplay's own preferences file as sufficient evidence that the system-level mode is active.

## Example Requests

- “这台 Mac 接外接屏有点糊，能不能调清晰一点？”
- “BetterDisplay 之前那台电脑调好了，这台怎么复现？”
- “This 2K monitor looks jagged on macOS. Can you get it closer to HiDPI?”
- “为什么外接屏换到另一台 Mac 以后就没有之前那种顺滑效果了？”
