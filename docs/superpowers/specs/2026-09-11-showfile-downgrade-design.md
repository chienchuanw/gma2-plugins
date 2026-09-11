# Showfile Downgrade — Design Spec

**Date:** 2026-09-11
**Status:** implemented and verified on console — see *Verified on console* at the end
**Origin:** optimising the three macros in
[chienchuanw/gma2-macros](https://github.com/chienchuanw/gma2-macros) (`macros/showfile-downgrade/`)
into a plugin pair.

## Problem

A grandMA2 showfile is forward-compatible only: a 3.9.60 show will not open on a
3.3.4 console, and `SaveShow` has no "save as older version" option. The
established workaround is to export every pool as XML, hand-edit the version
header of each file, and import them into an empty show on the old console.

The existing macro trio automates the export and the import. It does **not**
automate the hand-editing, which is the only manual step and the one that scales
with the number of pools. It also uses fixed `delay="1".."4"` waits, which a
large show can outrun silently.

## Scope

**In scope (v1):** reach macro parity — the same 13 pools — with the header
rewriting automated, the fixed delays replaced by real completion checks, and
the scratch-layer cleanup made safe.

**Out of scope (v2):** exporting pools the old macro omits. The Root map is now
known (see Findings) so this is a follow-up, not a redesign. Deferred because
importing new pools needs a new dependency order (a View references a Layout, so
it must import after one), and mixing that into v1 makes a failure impossible to
attribute.

**Out of scope (permanent):** the cross-machine / USB case. That is what the
macros remain for.

## Target environment

Both versions running as **onPC on the same Windows machine**. This is what makes
zero-USB, zero-manual-copy possible. Confirmed installed layout:

```
C:/ProgramData/MA Lighting Technologies/grandma/gma2_V_3.9.60
C:/ProgramData/MA Lighting Technologies/grandma/gma2_V_3.3.4
```

## Console findings (all probe-verified, 2026-09-11)

Established by `plugins/downgrade-probe/` across four iterations on a 331-fixture
3.9.60 show and a fresh 3.3.4 show.

| Finding | Value |
|---|---|
| Lua on 3.9.60 | 5.3 |
| `io.open` / `os.remove` / `os.rename` / `os.execute` | all present |
| Writing to the *other* version's tree | works |
| `os.execute "mkdir"` | works — a missing target folder can be created |
| `gma.show.getvar("path")` | `C:/ProgramData/.../gma2_V_3.9.60`, forward slashes, no trailing separator |
| Version substitution in that path | clean: last `%d+%.%d+[%.%d]*` match is the version |
| Every export file ends with | `</MA>` — this is the completion marker |
| `Export Root 13 "X"` | `/importexport/X.xml` |
| setup/3 → `Export * "X"` (fixture types) | `/library/X.xml` |
| setup/4 → `Export * "X"` (fixture layers) | `/fixture_layers/X.xml` |
| Multi-file exports | **do not happen** — one file per pool regardless of show size (568 KB for 1087 subfixtures) |
| `Export /path="<windows path>"` | accepted; can even write straight into the other version's tree |
| `ChangeDest <n>` argument | the object **number**, not the child index |
| LiveSetup | `Root 10`; children include `FixtureTypes` (number 3) and `Layers` (number 4) |
| EditSetup | `Root 11`; reports `children=0` unless the console is inside Full Access Setup |
| `ChangeDest 10` → `ChangeDest 4` → `Export *` | produces a byte-identical layers export to the EditSetup route |
| Entering EditSetup (`ChangeDest 11`) | makes DMX output unstable and forces a full fixture/preset type rebuild on exit |
| Fixture layer numbering | ~~starts at 2, there is no layer 1~~ **wrong** — see Verified: there is an `Auto-Created 1`, missed because the probe scanned from index 1 |
| `getobj.amount` on a pool collection | ~~over-reports by one~~ **misdiagnosed** — the child index base is 0 for these objects, so scanning from 1 loses the first entry and makes the count look one high. Also not a content count at all: `Root 13` reports one child whether the macro pool holds 0 or 58 macros |
| Views | no Root number; addressable as `View 1`, `View 2`, … |

### Root pool map

```
 8 UserImagePool   13 Macros        15 Plugins      16 Gels        17 Presets
18 Worlds          19 Filters       20 FadePaths    22 Groups      23 Forms
24 Effects         25 Sequences     26 Timers       27 MasterSections
30 ExecutorPages   31 ChannelPages  33 Songs        34 Agendas     35 Timecodes
36 RemoteTypes     37 DMXSnapshotPool              38 Layouts
39 UserProfiles    40 Users
```

No handle at 12, 28, 29, 32, 44, 45, 47–50. Root 46 is `Temp`.

### The `Delete 2` question

The old Import macro runs, with the destination set to the layer list:

```
Import "FixtureLayers" At 2 /o
Delete 2
```

Probing the 3.3.4 show after patching the scratch dimmer showed the scratch
layer at `number=2`, so before the import `Delete 2` does name it. What is
*not* established is whether the import renumbers: the source show's layers
carry numbers 2–27, so if they land on their original numbers the layer at 2
afterwards is `(GZ) LED` — a real 36-fixture layer — and the macro would destroy
it on every run.

**Resolution at design time: do not replicate the line.** The plugin was to read
the layer list before and after and match the scratch layer by identity.

**Superseded by measurement** — see *Verified on console* below. Identity does
not survive the import, and the answer to the question itself turned out to be
that the macro's `Delete 2` deletes nothing at all.

## Design

### Plugin 1 — Downgrade Export (runs on the high version)

1. Ask for the target version. Validate `major.minor.stream`; reject a target
   that is not lower than the running version.
2. Derive the sibling tree by substituting the version segment of
   `getvar("path")`. Probe-write to confirm it is writable; `mkdir` the
   subfolders if they are missing; abort with the attempted path if that fails.
3. `SelectDrive 1`, then export all 13 pools. After each, poll for the expected
   file until its content ends with `</MA>`, or time out at 60 s and record the
   failure without aborting the run.
4. For each exported file: read, rewrite the header to the target version, write
   the **copy** into the sibling tree at the same relative path. Originals are
   left untouched so a wrong target version can be corrected without
   re-exporting.
5. Copy `Downgrade Import.lua` from this console's `plugins/` folder into the
   sibling tree and generate a `.xml` descriptor carrying the target version's
   header, so the import plugin is already installed on the other side.
6. Report per pool: found, bytes, rewritten, or the failure reason.

### Plugin 2 — Downgrade Import (runs on the low version)

1. Warn that the show should be new and empty; abort on cancel.
2. Read the layer list through LiveSetup and record it.
3. Import each pool in dependency order, polling the destination pool's object
   count until it settles. The count is read through the pool's object keyword;
   the Root handle is not a content count.
4. Re-read the layer list and remove the leftover scratch layer, identified as
   the only layer holding no fixtures.
5. Report per pool, and state explicitly whether the scratch layer was removed.

### Pools, in export order

| key | export command | folder | file |
|---|---|---|---|
| `fixturetype` | setup → `3`, `Export * "FixtureType"` | `/library/` | `FixtureType.xml` |
| `fixturelayers` | setup → `4`, `Export * "FixtureLayers"` | `/fixture_layers/` | `FixtureLayers.xml` |
| `sequence` | `Export Root 25 "Sequence"` | `/importexport/` | `Sequence.xml` |
| `executorpages` | `Export Root 30 "ExecutorPages"` | `/importexport/` | `ExecutorPages.xml` |
| `groups` | `Export Root 22 "Groups"` | `/importexport/` | `Groups.xml` |
| `presets` | `Export Root 17 "Presets"` | `/importexport/` | `Presets.xml` |
| `layouts` | `Export Root 38 "Layouts"` | `/importexport/` | `Layouts.xml` |
| `userimagepool` | `Export Root 8 "UserImagePool"` | `/importexport/` | `UserImagePool.xml` |
| `macros` | `Export Root 13 "Macros"` | `/importexport/` | `Macros.xml` |
| `effects` | `Export Root 24 "Effects"` | `/importexport/` | `Effects.xml` |
| `timecodes` | `Export Root 35 "Timecodes"` | `/importexport/` | `Timecodes.xml` |
| `userprofiles` | `Export Root 39 "UserProfiles"` | `/importexport/` | `UserProfiles.xml` |
| `users` | `Export Root 40 "Users"` | `/importexport/` | `Users.xml` |

Import order matches the old macro: fixture types, fixture layers, user images,
effects, groups, layouts, presets, sequences, executor pages, timecodes, macros,
then user profiles and users last and separately.

The folder column is the expected location. Because only `Root 13` was probed
directly, the file locator sweeps `/importexport/`, `/library/` and
`/fixture_layers/` for `<name>.xml` rather than trusting the column, and the run
report names the folder each file was actually found in.

## Decisions taken during design

- **Two plugins, not one.** The import half has to run on the old console.
- **Fixed 13-pool list, no per-pool prompts.** These pools reference each other;
  letting a user deselect one produces a quietly broken show. (`Clean Showfile`
  prompts per pool because deletion is genuinely independent — this is not.)
- **Originals preserved, copies written across.** Cheap, and it makes a wrong
  target version recoverable without a re-export.
- **The import plugin's `.lua` is copied, not embedded.** One source of truth;
  embedding it as a string would need quote escaping, which has bitten this repo
  before.
- **The macros stay.** They cover the cross-machine case the plugins do not.
  Both READMEs cross-reference.

## Known data loss

Carried over from the macro's README and not addressed in v1: layouts assigned
into a view disappear, and preset-set default values are lost. The Root map
shows Views are not exported at all, which is consistent with the first symptom.
v1 warns about both in the final report.

## Acceptance

Downgrade the same source show twice — once with the old macros, once with the
plugins — and compare sequence, preset, group and layer counts plus spot-checked
content. A control run is what separates "the plugin is wrong" from "downgrading
loses this anyway".

## Open, non-blocking

- Whether `ChangeDest 10` avoids Full Access Setup. The export works either way;
  only the wording of the warning depends on it. v1 warns conservatively.
- Whether the scratch dimmer is needed at all, or whether layers import into a
  completely empty show. v1 requires a layer to exist and says so.

## Verified on console (2026-09-11)

Source: `2026_lucy_v3.9.60_beijing_downgrade` on 3.9.60.50, 331 fixtures / 1087
subfixtures. Target: a fresh show on 3.3.4.1 with one scratch dimmer. Snapshots
taken with `sandbox/downgrade-audit/`.

### Every exported pool matched exactly

| pool | source | plugin result |
|---|---|---|
| Macros | 58 | 58 |
| Groups | 67 | 67 |
| Sequences | 82 | 82 |
| Effects | 290 | 290 |
| Presets | 117 (43/16/30/14/14 by type) | 117 (identical per type) |
| Layouts | 10 | 10 |
| ExecutorPages | 23 | 23 |
| UserImagePool | 13 | 13 |
| UserProfiles | 3 / 78 | 3 / 78 |
| Users | 4 | 4 |
| Timecodes | 0 | 0 |
| fixture layers | 27 layers / 331 fixtures | same names, same per-layer counts, 331 |

The only structural difference is one extra empty layer at number 2, which
shifts the real layers up by one number. That is the emptied scratch layer.

### What is lost

- **Views: 86 → 4.** Total loss; the four are what a new show starts with. This
  corrects the old macro README's claim that "layouts assigned with the view
  will disappear": the Layouts pool comes through intact at 10, and it is the
  views arranging them that do not survive.
- **Channel count 7503 → 7495.** No fixture is missing — every layer's fixture
  count matches — so this is a fixture type with a different channel count in
  the 3.3.4 library, not lost patch.
- Preset default values are reported lost by the original macro README. This
  comparison did not measure them; the claim is carried forward unverified.

### The `Delete 2` question, answered

Running the old macros produced 27 layers with the scratch layer alive at
number 28 and `(GZ) LED` intact at number 2 — so `Delete 2` deleted nothing at
all. It is not safe-by-design, it is broken: the import *does* renumber, the
real layers *do* land on 2 upwards, and a `Delete 2` that actually executed
would have removed a 36-fixture production layer.

### Why identity matching was abandoned

The scratch layer came back renamed, emptied and renumbered, differently in each
route: `test 2` → `test 28` under the macros, `test 2` → `Auto-Created 2` with
zero fixtures under the plugin. `getobj.name` compounds this by appending the
object's own number to the label, so even the name changes on renumbering.

What held in both runs is that the leftover is the only layer with no fixtures.
Both outcomes are encoded as test cases in `tests/downgrade-import/test_logic.lua`.

### Corrections this run forced

- `getobj.amount` on a pool collection is not a content count. `Root 13` reports
  one child whether the macro pool holds nothing or 58 macros. Counting must go
  through the object keyword, scanning from index 0 with `getobj.verify`, as
  `Clean Showfile` already did.
- The plugins folder path must be discovered, not assumed.

### The plugin install step, resolved

It failed because the design assumed both plugins live under
`gma2_V_<version>/plugins/`. They do not: plugins are imported straight off a
USB stick here, so nothing in the console tree holds a copy of the `.lua` at all.

Reframed rather than patched. The `.lua` is already on that USB stick and can be
imported on the target console from the same stick; the part that actually needs
automating is the `.xml` descriptor, because it has to carry the target
version's header and hand-editing that is the chore this plugin exists to
remove. So the descriptor is now always written, the `.lua` is copied when it
can be found - the search sweeps `D:` through `Z:` as well as the console tree -
and a missing source costs one file copy instead of the whole step.

### The onPC folder is not always named after the full version

Verified installations:

```
3.9.60 -> gma2_V_3.9.60      3.3.4 -> gma2_V_3.3.4
3.7.0  -> gma2_V_3.7         3.9.0 -> gma2_V_3.9
```

A trailing `.0` is dropped. Deriving the folder name from the target version
alone therefore produced `gma2_V_3.7.0` for a 3.7.0 target, which `mkdir`
happily created next to the real `gma2_V_3.7` — so a run reported all 13 pools
written and every byte of it went into a folder the console never reads. A
silent success is the worst possible failure here.

The rule is now used only to order two candidate names. Which one is real is
settled by probing: a temp file is written into `<candidate>/importexport/`
**without** creating anything, and the first candidate that accepts it wins. If
neither does, the run aborts before exporting and says the target onPC does not
appear to be installed. That self-corrects for any naming not seen here.

### Still open

- `getobj.handle` returns nothing for `Image`, `UserProfile` and `User` on
  3.9.60, so those three pools report "no count available" and fall back to a
  fixed settle. Cosmetic; the correct keywords are unknown.
- Whether `ChangeDest 10` avoids Full Access Setup was never confirmed. The
  warning stays.
