# Correct Position Offset — Design Spec

**Date:** 2026-06-28
**Status:** Approved, pending implementation
**Target console:** grandMA2 3.9.60

## Summary

A first-party grandMA2 plugin that bakes the difference between two **Position
presets** into each fixture's per-instance **Pan/Tilt offset**. Given an
"original" preset and a "corrected" preset, for every fixture instance present
in both, it computes `corrected − original` for Pan and Tilt and **adds** that
delta to the instance's current offset.

Use case: a rig has been physically re-focused into a corrected position
preset that differs from what was originally programmed. Rather than
re-recording every cue that uses the original preset, this writes the
positional difference into each fixture's calibration offset, so all existing
programming that references the original preset now points correctly.

This is a **clean-room reimplementation** of the *concept* behind the
proprietary "Presets to Offsets" plugin (© Jason Giaffo / Giaffo Designs). No
code from that plugin is copied or adapted; the XML format and `gma.*` API
usage are derived from MA's own exported showfiles and reference samples. This
plugin is original work by the repository owner, MIT-licensed.

## Background: why the original only reached `.1`

The proprietary plugin parsed each preset's exported XML but its regex only
captured `fixture_id` / `channel_id` — it **never read `subfixture_id`**. For a
multi-instance fixture (e.g. ACME Tornado TB5, which has 5 Pan/Tilt instances
`.1 .3 .5 .7 .9`), all five instances share the same `fixture_id`, so they
collided on one table key and overwrote each other; the surviving value was
then written only to sub-fixture `.1`. The remaining instances (`.3 .5 .7 .9`),
which carry real Pan/Tilt values, were silently dropped.

**This design fixes that by keying data per instance (`fixture_id` +
`subfixture_id`) and writing the offset back to the exact sub-fixture.**

## Exported preset XML format (confirmed from a real 3.9.60 export)

`Export Preset 2.<n> "<name>" /nc` writes to `<showpath>/importexport/<name>.xml`:

```xml
<MA ...>
  <Preset index="57" SpecialUse="Normal">
    <Values>
      <Channels>
        <PresetValue Value="-30.874996">
          <Channel fixture_id="201" attribute_name="PAN" />
        </PresetValue>
        <PresetValue Value="-20.149973">
          <Channel fixture_id="201" subfixture_id="3" attribute_name="PAN" />
        </PresetValue>
        <!-- ... TILT entries, subfixture_id 5/7/9, more fixtures ... -->
      </Channels>
    </Values>
  </Preset>
</MA>
```

Observed facts:
- Each `<PresetValue Value="...">` wraps one `<Channel .../>`.
- `attribute_name` is uppercase **`PAN`** / **`TILT`** (other attributes may
  appear in a position preset and must be ignored).
- Instance 1 has **no** `subfixture_id`; instances 3/5/7/9 carry
  `subfixture_id="N"`. Absent ⇒ sub-fixture `1`.
- Channels are identified by `fixture_id` **or** `channel_id`. The sample
  contained only `fixture_id`, but `channel_id` support is retained for
  channel-patched rigs.
- The `<Preset index>` value is not needed — each export is parsed for all its
  `PresetValue`s; we export the two presets into separate files.

## Configuration (top-of-file `CONFIG`, edit-to-set — mirrors `local DEBUG`)

```lua
local CONFIG = {
  OFFSET_PAN  = true,   -- apply Pan offsets
  OFFSET_TILT = true,   -- apply Tilt offsets
}
local DEBUG = false     -- echo progress to System Monitor (absorbs the old VERBOSE flag)
```

At least one of `OFFSET_PAN` / `OFFSET_TILT` must be true, else abort with a
message.

## Flow

```
Start()
  1. Validate CONFIG (at least one axis enabled).
  2. textinput × 2: "Original preset number" and "Corrected preset number"
     (default "1"; Cancel on either ⇒ abort quietly).
  3. Guard: O.handle("Preset 2.<orig>") and ("Preset 2.<corr>") both exist,
     else msgbox + abort.
  4. For each of {orig, corrected}: export_and_read → parse_preset.
  5. Build deltas: intersection of instance keys present in BOTH presets,
     per enabled attribute. delta = corrected − orig.
  6. Guard: if no common instances produced any delta ⇒ msgbox + abort.
  7. For each instance: read current offset(s), add delta(s), issue one
     combined Assign.
  8. Completion msgbox + feedback: instances applied, Pan count, Tilt count,
     the two preset numbers.
Cleanup()
  - On failure (PLUGIN_COMPLETE not set) ⇒ msgbox pointing to System Monitor.
```

## Module boundaries (single file, focused functions)

- `export_and_read(preset_no) -> xml | nil`
  `SelectDrive 1`; remove stale tmp; `Export Preset 2.<n> "<tmp>" /nc`; poll
  `importexport/<tmp>.xml` until it contains `</MA>` (≤ ~2 s); return contents.
  Reuses the proven pattern from `Update Info` (async `gma.cmd`, `gma.sleep`
  poll, `</MA>` completion marker, internal-drive path).
- `parse_preset(xml) -> { [attr] = { [key] = value } }`
  `attr` ∈ `pan` / `tilt`; `key` = `"<idtype>:<id>.<sub>"`. Iterate
  `<PresetValue ...>...</PresetValue>` blocks; from the inner `<Channel>` read
  `Value`, `fixture_id`/`channel_id`, optional `subfixture_id` (default 1),
  `attribute_name` (lowercased, keep only pan/tilt).
- `read_offset(target, prop) -> number`
  `prop` ∈ `"panoffset"` / `"tiltoffset"`. `gma.show.property.get(O.handle(
  target), prop)`; `tonumber(...)` or `0` if nil/unreadable (DEBUG logs it).
  **Property name to be verified on-console; the nil→0 fallback keeps the
  plugin functional if a name differs.**
- `apply_offsets(deltas) -> {pan=ct, tilt=ct, instances=ct}`
  Group deltas by instance key; for each, read current offset for each changed
  axis, accumulate, and send one `Assign Fixture <id>.<sub> /panoffset=%.3f
  /tiltoffset=%.3f` (only the changed axes included). Channel targets use
  `Assign Channel <id>.<sub> ...`.

## Write command shape

```
Assign Fixture 201.3 /panoffset=12.345 /tiltoffset=-4.000
```
- Sub-fixture suffix built from `subfixture_id` (default `1`).
- Pan and Tilt combined into one Assign per instance (≤ N commands, not 2N).
- `%.3f` formatting, matching the precision seen in exported values.

## Error handling & guards

| Condition | Behaviour |
|---|---|
| Both axes disabled in CONFIG | msgbox, abort |
| Cancel on either input box | quiet feedback, abort (no changes) |
| A preset doesn't exist | msgbox naming the missing preset, abort |
| Export/read fails (no `</MA>`) | msgbox (export/read error), abort |
| No common instances / no deltas | msgbox ("nothing to apply"), abort |
| Offset property unreadable | treat current as 0, continue, DEBUG logs it |

## Non-goals (YAGNI)

- No progress bar (operations complete near-instantly).
- No debug-file writing to `/gma2/reports/` — `DEBUG` → `gma.echo` only.
- No preset types other than Position (`Preset 2.x`).
- No embedded framework — direct `gma.*` calls in this repo's first-party style.

## Packaging

- `plugins/correct-position-offset/Correct Position Offset.lua`
- `plugins/correct-position-offset/Correct Position Offset.xml`
  (3.9.60 schema, copied from an existing first-party `.xml`)
- UI text English; comments zh-TW; `return Start, Cleanup`.
- Picked up automatically by `scripts/build-release.sh` →
  `dist/correct-position-offset.zip`.
- README updated in all four spots (feature list, download links, usage,
  structure tree), consistent with prior plugins.

## Open item requiring on-console verification

The offset property names (`panoffset` / `tiltoffset`) and that
`gma.show.property.get(handle, name)` returns them as a number-like string.
The `nil → 0` fallback degrades gracefully if a name differs; DEBUG output will
reveal the actual readable property names during manual testing.
