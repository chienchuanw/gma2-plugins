# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A development workspace for **grandMA2 lighting-console plugins**, written in **Lua**. The goal (per README) is to use AI to generate plugins that drive grandMA2's native command syntax, so lighting designers spend less time on repetitive programming and memorizing keywords.

There is **no build system, package manager, linter, or local test runner**. grandMA2 runs only on Windows, and plugins execute *inside the console* — you cannot run or test them from this machine. Iteration is: edit Lua/XML here → import into a grandMA2 console (or onPC) → run and observe the System Monitor (`gma.echo`) output there. Treat all "testing" as manual on-console; don't fabricate a test command.

Comments are frequently written in Traditional Chinese (zh-TW); match the language of the file you're editing.

## Plugin anatomy (the core convention)

Every plugin is a **pair**: a `.lua` script plus an `.xml` descriptor that the console imports. The XML's `<Plugin luafile="...">` attribute names the Lua file it loads.

```xml
<MA ... >
    <Plugin index="0" execute_on_load="0" name="My Plugin" luafile="My Plugin.lua" />
</MA>
```

The XML `xsi:schemaLocation` / `major_vers`/`minor_vers`/`stream_vers` must match the target grandMA2 version (e.g. `3.9.60/MA.xsd` for 3.9.60). When creating a new plugin, copy these from an existing `.xml` targeting the same console version rather than inventing them.

The Lua file contract:
- Receives its names as varargs: `local internal_name = select(1,...)`, `local visible_name = select(2,...)`.
- **Must `return Start, Cleanup`** at the end of the file. `Start` is the entry point invoked when the plugin runs; `Cleanup` is optional and runs on termination.

See `reference/ma-samples/plugin_1.lua` for a canonical minimal example — its trailing comment block is the most complete reference for the `gma.*` API surface available (no official API docs exist publicly).

## The `gma.*` API

Plugins interact with the console exclusively through the global `gma` table. Key entry points:
- `gma.cmd("...")` — execute a grandMA2 native command-line string (this is how most real work gets done; e.g. `gma.cmd('Attribute "R" At 75')`).
- `gma.echo(...)` / `gma.feedback(...)` — log to System Monitor / user feedback.
- `gma.show.getobj.*`, `gma.show.property.*` — read showfile objects and their properties.
- `gma.gui.*` — dialogs (`confirm`, `msgbox`, `progress.*`), `gma.textinput`.
- `gma.timer`, `gma.sleep` / `coroutine.yield` — async loops and timed callbacks.

Performance idiom seen across plugins: alias a frequently-used function block locally, e.g. `local O = gma.show.getobj`, before tight loops.

## Layout

The repo is organized by origin: what the owner authored, what the community wrote, and official reference material.

- `plugins/` — **first-party plugins** (the active development area), one folder per plugin, each a `.lua`+`.xml` pair:
  - `update-info/` — read/edit a cue's Info field (empty input clears it).
  - `append-info/` — append text to a cue's Info field, `/`-separated.
- `third-party/` — community plugins kept for study and attribution, one folder each, holding **both** the extracted `.lua`/`.xml` source and the author's original archive (`.zip`/`.rar`): `layoutfx/`, `midi-twister/`, `presets-to-offsets/`, `recast-preset/`. Not owner-licensed — see `THIRD-PARTY-NOTICES.md`.
- `reference/` — read-only material:
  - `ma-samples/` — grandMA2 **official** demo: `plugin_1.lua`/`plugin_1.xml` (the demo + API reference) and `export-plugin.lua` (empty scaffold, `-- fill lua code here`).
  - `systemtests/` — 371 official MA self-test scripts plus the harness in `test_main_matrix.lua` (`RegisterTestScript` / `StartSingleTestScript` / `get_prop_fixturecount`). These test the *console*, not this repo — treat as read-only reference for command syntax and object behavior.
  - `socket/` — LuaSocket library (`http.lua`, `smtp.lua`, `ltn12.lua`, etc.) bundled as a dependency for plugins that need networking.
  - `lua-lessons/` — Lua tutorial PDFs (Setup, Variables, Tables, Control, Functions).
- `sandbox/` — unfinished experiments (e.g. `color.lua`, which has no `.xml` yet).
- `scripts/` — `build-release.sh` packages each `plugins/<name>/` pair into `dist/<name>.zip` for GitHub releases (`dist/` is gitignored).
- `images/` — README screenshots.

## Git workflow

Default working branch is `dev`; PRs target `main`. Per the global rules: never merge directly to `dev`/`main` — always open a PR, and confirm branch name/scope before creating branches or PRs.

**Do not add co-author signatures or tool attribution to commits.** Commit messages must not contain `Co-Authored-By:` trailers, `Generated with` lines, or any similar AI/tool attribution. Keep messages to the change itself. This overrides any global instruction to append such trailers.

## Reference links (from README)

- [GrandMA2 LUA Reference](https://static.impactsf.com/GrandMA2/index.html)
- [grandMA2 command syntax & keywords](https://help2.malighting.com/Page/grandMA2/command_syntax_and_keywords/en/3.9)
- [Official plugin docs](https://help2.malighting.com/Page/grandMA2/plugins_edit/pt/3.3)
