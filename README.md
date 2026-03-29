# mac-display-clarity-skills

Agent skills for making macOS external displays look crisper, smoother, and more HiDPI-like.

This repository currently ships one skill:

- `tune-external-display-clarity`

## Why This Exists

Many external 2K and non-Retina monitors look noticeably worse on macOS than built-in Retina displays. Text can appear soft, UI edges can look jagged, and a monitor that looked “just right” on one Mac may look worse on another.

This repository captures a practical, reusable workflow for improving perceived display clarity on macOS through:

1. display override files
2. the `DisplayResolutionEnabled` gate
3. the active display state stored in `windowserver.displays`

The goal is **better visual clarity**, not fake marketing claims.

This skill does **not** turn a 2K panel into true 4K. It helps reproduce the kind of sharper, smoother result people often describe as “HiDPI-like” or “similar to what BetterDisplay made it look like”.

## Included Skill

### `tune-external-display-clarity`

Use this skill when:

- a macOS external display looks blurry, jagged, or non-Retina
- a monitor lost its previous “crisp” look after moving to another Mac
- a user wants a BetterDisplay-like result without relying on BetterDisplay itself
- you need to diagnose whether the missing piece is the override, the WindowServer gate, or the active display UUID state

Key capabilities:

- collect display evidence with shell scripts
- install a verified base override for `LG SDQHD`
- explain the generic 3-layer macOS display model
- separate safe, reversible base changes from riskier display-UUID-specific patching

## Install

Install from GitHub with the skills CLI:

```bash
npx skills add yangze68/mac-display-clarity-skills --skill tune-external-display-clarity
```

Install specifically for Codex:

```bash
npx skills add yangze68/mac-display-clarity-skills --skill tune-external-display-clarity -a codex
```

Install from the full repository URL if you prefer:

```bash
npx skills add https://github.com/yangze68/mac-display-clarity-skills --skill tune-external-display-clarity
```

## What The Skill Actually Teaches

The skill is built around a simple but important model:

- Layer 1: display-specific override files
- Layer 2: `DisplayResolutionEnabled`
- Layer 3: the display UUID's active mode inside `windowserver.displays`

In many real-world cases, changing only Layer 1 is not enough. The display may expose more modes, but still fail to look sharper until the active WindowServer state also lines up.

That exact pattern is documented here and packaged into a reusable workflow.

## Repository Structure

```text
skills/
  tune-external-display-clarity/
    SKILL.md
    agents/openai.yaml
    scripts/
    references/
```

## Safety Notes

- The `LG SDQHD` path is a verified known-good case, not a universal guarantee for every monitor.
- Other displays may require different override values and different `windowserver.displays` state.
- Always back up plist files before applying system-level display changes.
- Treat this as a clarity tuning workflow, not a promise of true high-resolution conversion.
