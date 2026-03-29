# mac-display-clarity-skills

Skills for improving perceived sharpness on macOS external displays.

This repository currently includes:

- `tune-external-display-clarity`

## What This Skill Does

The skill helps diagnose and improve blurry or jagged external displays on macOS by working through:

1. display override files
2. `DisplayResolutionEnabled`
3. `windowserver.displays` active mode state

It is designed for “clearer / HiDPI-like / smoother” results on external monitors.

It does **not** claim to turn a 2K panel into true 4K.

## Install

Install from GitHub with the skills CLI:

```bash
npx skills add yangze68/mac-display-clarity-skills --skill tune-external-display-clarity
```

Install specifically for Codex:

```bash
npx skills add yangze68/mac-display-clarity-skills --skill tune-external-display-clarity -a codex
```

## Included Skill

### `tune-external-display-clarity`

Use when a macOS external display looks blurry, jagged, or non-Retina, or when reproducing BetterDisplay-like HiDPI-style clarity on another Mac.

Key capabilities:

- collect display evidence with shell scripts
- install a verified base override for `LG SDQHD`
- explain the generic 3-layer macOS display model
- distinguish between safe base override work and display-UUID-specific WindowServer patching

## Repository Structure

```text
skills/
  tune-external-display-clarity/
    SKILL.md
    agents/openai.yaml
    scripts/
    references/
```

## Notes

- The `LG SDQHD` path is a verified known-good case.
- Other displays may need a different override and different `windowserver.displays` values.
- Always back up plist files before applying system-level display changes.
