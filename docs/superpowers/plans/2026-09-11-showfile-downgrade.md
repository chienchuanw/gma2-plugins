# Showfile Downgrade Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the three `showfile-downgrade` macros with a plugin pair that exports every pool, rewrites each file's version header automatically, and imports the result into an old-version console — with no hand-editing, no USB, and no hardcoded `Delete 2`.

**Architecture:** Two self-contained Lua plugins. `Downgrade Export` runs on the high version: it exports 13 pools, waits for each file's `</MA>` terminator instead of a fixed delay, rewrites the header into a copy placed in the other version's tree, and installs `Downgrade Import` there. `Downgrade Import` runs on the low version: it records the fixture-layer list, imports each pool while polling its object count, then removes the scratch layer by identity rather than by number. Each plugin keeps its pure logic at the top of the file and exports it when the global `gma` is nil, so it is unit-testable off-console.

**Tech Stack:** Lua 5.1-compatible (the import half must load on 3.3.4; the export half may assume 5.3), the `gma.*` console API, no external dependencies.

**Spec:** `docs/superpowers/specs/2026-09-11-showfile-downgrade-design.md`

## Global Constraints

- New plugins are written with **English comments** (the zh-TW convention applies only to pre-existing files).
- Every plugin is a `.lua` + `.xml` pair; the Lua file must `return Start, Cleanup` on console and the pure-function table off-console.
- Plugin XML header for the high-version plugin: `xsi:schemaLocation=".../xml/3.9.60/MA.xsd" major_vers="3" minor_vers="9" stream_vers="60"`.
- Tests run from the repo root: `lua tests/<plugin>/test_logic.lua`. No test framework; use the `eq()` counter pattern from `tests/repatch-from-layer/test_logic.lua`.
- Never hardcode a layer number in a delete command.
- `gma.show.getobj.amount` over-reports pool collections by one. Any count logic must tolerate it.
- Commit messages carry no `Co-Authored-By:` trailer and no tool attribution.
- Nothing in this plan can be verified on this machine. Console verification is Task 9 and is the user's to run.

---

### Task 1: Version parsing and comparison

**Files:**
- Create: `plugins/downgrade-export/Downgrade Export.lua`
- Create: `tests/downgrade-export/test_logic.lua`

**Interfaces:**
- Produces: `M.parse_version(s) -> major, minor, stream | nil`, `M.normalize_version(s) -> "a.b.c" | nil`, `M.version_lt(a, b) -> bool | nil`

- [x] **Step 1: Write the failing test**

```lua
local PLUGIN = "plugins/downgrade-export/Downgrade Export.lua"
local M = assert(loadfile(PLUGIN))()

local maj, min, str = M.parse_version("3.3.4")
eq(maj, 3, "major") eq(min, 3, "minor") eq(str, 4, "stream")
eq(M.parse_version("3.9.60"), 3, "3.9.60 major")
eq((select(3, M.parse_version("3.9.60"))), 60, "stream is 60 not 6")
eq(M.parse_version("3.9"), nil, "two components rejected")
eq(M.parse_version("3.9.60.50"), nil, "four components rejected as a target")
eq(M.parse_version(""), nil, "empty rejected")
eq(M.parse_version(nil), nil, "nil rejected")

-- getvar("VERSION") returns four components; the target only ever has three.
eq(M.normalize_version("3.9.60.50"), "3.9.60", "console version truncated")
eq(M.normalize_version("3.3.4.1"), "3.3.4", "low console version truncated")

eq(M.version_lt("3.3.4", "3.9.60"), true, "3.3.4 is lower")
eq(M.version_lt("3.9.60", "3.3.4"), false, "3.9.60 is not lower")
eq(M.version_lt("3.9.60", "3.9.60"), false, "equal is not lower")
eq(M.version_lt("3.9.6", "3.9.60"), true, "6 < 60 numerically, not as a string")
```

- [x] **Step 2: Run test to verify it fails**

Run: `lua tests/downgrade-export/test_logic.lua`
Expected: FAIL — the plugin file does not exist yet.

- [x] **Step 3: Write minimal implementation**

```lua
local M = {}

function M.parse_version(s)
    if type(s) ~= "string" then return nil end
    local a, b, c = string.match(s, "^%s*(%d+)%.(%d+)%.(%d+)%s*$")
    if not a then return nil end
    return tonumber(a), tonumber(b), tonumber(c)
end

-- gma.show.getvar("VERSION") answers "3.9.60.50"; the fourth component is the
-- build and never appears in a showfile header.
function M.normalize_version(s)
    if type(s) ~= "string" then return nil end
    local a, b, c = string.match(s, "^%s*(%d+)%.(%d+)%.(%d+)")
    if not a then return nil end
    return a .. "." .. b .. "." .. c
end

function M.version_lt(a, b)
    local a1, a2, a3 = M.parse_version(a)
    local b1, b2, b3 = M.parse_version(b)
    if not a1 or not b1 then return nil end
    if a1 ~= b1 then return a1 < b1 end
    if a2 ~= b2 then return a2 < b2 end
    return a3 < b3
end
```

- [x] **Step 4: Run test to verify it passes**

Run: `lua tests/downgrade-export/test_logic.lua`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add "plugins/downgrade-export/Downgrade Export.lua" tests/downgrade-export/test_logic.lua
git commit -m "feat(downgrade-export): parse and compare grandMA2 version strings"
```

---

### Task 2: XML header rewriting

**Files:**
- Modify: `plugins/downgrade-export/Downgrade Export.lua`
- Modify: `tests/downgrade-export/test_logic.lua`
- Create: `tests/downgrade-export/fixtures/macros-3.9.60.xml`

**Interfaces:**
- Consumes: `M.parse_version`
- Produces: `M.rewrite_header(xml, target) -> new_xml, 4 | nil, reason`, `M.is_complete(xml) -> bool`

The fixture is a minimal but real-shaped export: the exact header the console
writes, one object, and the `</MA>` terminator.

- [x] **Step 1: Write the failing test**

```lua
local FIX = "tests/downgrade-export/fixtures/"
local src = slurp(FIX .. "macros-3.9.60.xml")

local out, n = M.rewrite_header(src, "3.3.4")
eq(n, 4, "four header fields replaced")
eq(string.find(out, 'major_vers="3"', 1, true) ~= nil, true, "major stays 3")
eq(string.find(out, 'minor_vers="3"', 1, true) ~= nil, true, "minor becomes 3")
eq(string.find(out, 'stream_vers="4"', 1, true) ~= nil, true, "stream becomes 4")
eq(string.find(out, "xml/3.3.4/MA.xsd", 1, true) ~= nil, true, "schema url rewritten")
eq(string.find(out, "xml/3.9.60/MA.xsd", 1, true), nil, "no 3.9.60 left")

-- The XML declaration also contains version="1.0". It must survive untouched.
eq(string.find(out, '<?xml version="1.0" encoding="utf-8"?>', 1, true) ~= nil, true,
   "xml declaration untouched")

-- Body must be byte-identical apart from the header line.
eq(string.find(out, "<text>Macro &quot;Song Change&quot;</text>", 1, true) ~= nil, true,
   "body preserved")
eq(#out - #src, #("3.3.4") - #("3.9.60") + 0 - 1, "only the header changed length")

eq(M.rewrite_header(src, "nonsense"), nil, "bad target rejected")
eq(M.rewrite_header("<MA></MA>", "3.3.4"), nil, "missing header fields rejected")

eq(M.is_complete(src), true, "fixture ends with </MA>")
eq(M.is_complete("<MA>\n</MA>\n"), true, "trailing newline allowed")
eq(M.is_complete("<MA><Macro"), false, "truncated export detected")
eq(M.is_complete(""), false, "empty file is not complete")
eq(M.is_complete(nil), false, "nil is not complete")
```

- [x] **Step 2: Run test to verify it fails**

Run: `lua tests/downgrade-export/test_logic.lua`
Expected: FAIL with "attempt to call a nil value (field 'rewrite_header')"

- [x] **Step 3: Write minimal implementation**

```lua
-- Rewrites the four version fields of an MA export header and nothing else.
-- The schema pattern deliberately anchors on "/grandma2/xml/<digits>/MA.xsd" so
-- it cannot touch the xmlns that ends "/grandma2/xml/MA", and the three
-- *_vers attributes are matched by name so the <?xml version="1.0"?>
-- declaration is never a candidate.
function M.rewrite_header(xml, target)
    if type(xml) ~= "string" then return nil, "not a string" end
    local maj, min, str = M.parse_version(target)
    if not maj then return nil, "target version must look like 3.3.4" end

    local n, c = 0, 0
    local out = xml
    out, c = string.gsub(out, "(/grandma2/xml/)[%d%.]+(/MA%.xsd)", "%1" .. target .. "%2", 1)
    n = n + c
    out, c = string.gsub(out, 'major_vers="%d+"', 'major_vers="' .. maj .. '"', 1)
    n = n + c
    out, c = string.gsub(out, 'minor_vers="%d+"', 'minor_vers="' .. min .. '"', 1)
    n = n + c
    out, c = string.gsub(out, 'stream_vers="%d+"', 'stream_vers="' .. str .. '"', 1)
    n = n + c

    if n < 4 then
        return nil, string.format("header incomplete: %d of 4 fields matched", n)
    end
    return out, n
end

-- Every export the console writes ends with </MA>. Polling for that is how this
-- plugin knows a file is finished, instead of the macro's fixed delays.
function M.is_complete(xml)
    return type(xml) == "string" and string.find(xml, "</MA>%s*$") ~= nil
end
```

- [x] **Step 4: Run test to verify it passes**

Run: `lua tests/downgrade-export/test_logic.lua`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add "plugins/downgrade-export/Downgrade Export.lua" tests/downgrade-export/
git commit -m "feat(downgrade-export): rewrite export headers to a target version"
```

---

### Task 3: Sibling path derivation and file location

**Files:**
- Modify: `plugins/downgrade-export/Downgrade Export.lua`
- Modify: `tests/downgrade-export/test_logic.lua`

**Interfaces:**
- Consumes: `M.parse_version`
- Produces: `M.sibling_path(base, target) -> path | nil`, `M.SEARCH_DIRS`, `M.candidates(name) -> { "dir/name.xml", ... }`

- [x] **Step 1: Write the failing test**

```lua
local BASE = "C:/ProgramData/MA Lighting Technologies/grandma/gma2_V_3.9.60"
eq(M.sibling_path(BASE, "3.3.4"),
   "C:/ProgramData/MA Lighting Technologies/grandma/gma2_V_3.3.4",
   "version segment substituted")

-- Only the last version-looking run is replaced: a user folder could contain
-- digits and dots of its own.
eq(M.sibling_path("D:/shows/2026.01.09/grandma/gma2_V_3.9.60", "3.3.4"),
   "D:/shows/2026.01.09/grandma/gma2_V_3.3.4",
   "earlier dotted run left alone")
eq(M.sibling_path("C:/no/version/here", "3.3.4"), nil, "no version segment")
eq(M.sibling_path(BASE, "bad"), nil, "bad target rejected")
eq(M.sibling_path(nil, "3.3.4"), nil, "nil base rejected")

local c = M.candidates("Sequence")
eq(c[1], "/importexport/Sequence.xml", "importexport searched first")
eq(#c, 3, "three folders searched")
eq(c[2], "/library/Sequence.xml", "library second")
eq(c[3], "/fixture_layers/Sequence.xml", "fixture_layers third")
```

- [x] **Step 2: Run test to verify it fails**

Run: `lua tests/downgrade-export/test_logic.lua`
Expected: FAIL with "attempt to call a nil value (field 'sibling_path')"

- [x] **Step 3: Write minimal implementation**

```lua
-- The console's own path carries its version, so the other version's tree is
-- the same string with that segment swapped. Probed: getvar("path") answers
-- "C:/ProgramData/MA Lighting Technologies/grandma/gma2_V_3.9.60".
function M.sibling_path(base, target)
    if type(base) ~= "string" then return nil end
    if not M.parse_version(target) then return nil end

    local s, e, init = nil, nil, 1
    while true do
        local a, b = string.find(base, "%d+%.%d+[%.%d]*", init)
        if not a then break end
        s, e, init = a, b, b + 1
    end
    if not s then return nil end
    return string.sub(base, 1, s - 1) .. target .. string.sub(base, e + 1)
end

-- Only "Export Root 13" was probed directly, so the exact folder per pool is not
-- guaranteed. Probing all three known export folders costs nothing (io.open on a
-- missing file just returns nil) and the run report names where each file landed.
M.SEARCH_DIRS = { "/importexport/", "/library/", "/fixture_layers/" }

function M.candidates(name)
    local out = {}
    for _, dir in ipairs(M.SEARCH_DIRS) do
        out[#out + 1] = dir .. name .. ".xml"
    end
    return out
end
```

- [x] **Step 4: Run test to verify it passes**

Run: `lua tests/downgrade-export/test_logic.lua`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add "plugins/downgrade-export/Downgrade Export.lua" tests/downgrade-export/test_logic.lua
git commit -m "feat(downgrade-export): derive the sibling tree and locate exports"
```

---

### Task 4: Pool table and export commands

**Files:**
- Modify: `plugins/downgrade-export/Downgrade Export.lua`
- Modify: `tests/downgrade-export/test_logic.lua`

**Interfaces:**
- Produces: `M.POOLS` (ordered array of `{ key, file, dir, root | setup }`), `M.export_cmd(pool) -> string`, `M.plugin_descriptor(target, luafile, name) -> string`

- [x] **Step 1: Write the failing test**

```lua
eq(#M.POOLS, 13, "thirteen pools, matching the old macro")
eq(M.POOLS[1].key, "fixturetype", "fixture types export first")
eq(M.POOLS[1].setup, 3, "fixture types live at setup number 3")
eq(M.POOLS[2].key, "fixturelayers", "fixture layers second")
eq(M.POOLS[2].setup, 4, "fixture layers at setup number 4")
eq(M.POOLS[2].dir, "/fixture_layers/", "layers land in fixture_layers")

local by_key = {}
for _, p in ipairs(M.POOLS) do by_key[p.key] = p end
eq(by_key.macros.root, 13, "Macros is Root 13")
eq(by_key.presets.root, 17, "Presets is Root 17")
eq(by_key.groups.root, 22, "Groups is Root 22")
eq(by_key.effects.root, 24, "Effects is Root 24")
eq(by_key.sequence.root, 25, "Sequences is Root 25")
eq(by_key.executorpages.root, 30, "ExecutorPages is Root 30")
eq(by_key.timecodes.root, 35, "Timecodes is Root 35")
eq(by_key.layouts.root, 38, "Layouts is Root 38")
eq(by_key.userprofiles.root, 39, "UserProfiles is Root 39")
eq(by_key.users.root, 40, "Users is Root 40")
eq(by_key.userimagepool.root, 8, "UserImagePool is Root 8")

eq(M.export_cmd(by_key.macros), 'Export Root 13 "Macros"/o', "root pool export")
eq(M.export_cmd(M.POOLS[2]), 'Export * "FixtureLayers"/o', "setup export uses *")

local xml = M.plugin_descriptor("3.3.4", "Downgrade Import.lua", "Downgrade Import")
eq(string.find(xml, 'major_vers="3" minor_vers="3" stream_vers="4"', 1, true) ~= nil, true,
   "descriptor carries the target version")
eq(string.find(xml, 'xml/3.3.4/MA.xsd', 1, true) ~= nil, true, "descriptor schema url")
eq(string.find(xml, 'luafile="Downgrade Import.lua"', 1, true) ~= nil, true, "descriptor luafile")
eq(M.plugin_descriptor("bad", "x.lua", "x"), nil, "bad version rejected")
```

- [x] **Step 2: Run test to verify it fails**

Run: `lua tests/downgrade-export/test_logic.lua`
Expected: FAIL with "attempt to get length of a nil value (field 'POOLS')"

- [x] **Step 3: Write minimal implementation**

```lua
-- Export order, matching the old macro. Root numbers were read off the console
-- (see the spec's Root pool map). "setup" entries are not Root pools: they are
-- reached by navigating into the setup tree, where the number is the object
-- number and not the child index.
M.POOLS = {
    { key = "fixturetype",   file = "FixtureType",   dir = "/library/",        setup = 3  },
    { key = "fixturelayers", file = "FixtureLayers", dir = "/fixture_layers/", setup = 4  },
    { key = "sequence",      file = "Sequence",      dir = "/importexport/",   root  = 25 },
    { key = "executorpages", file = "ExecutorPages", dir = "/importexport/",   root  = 30 },
    { key = "groups",        file = "Groups",        dir = "/importexport/",   root  = 22 },
    { key = "presets",       file = "Presets",       dir = "/importexport/",   root  = 17 },
    { key = "layouts",       file = "Layouts",       dir = "/importexport/",   root  = 38 },
    { key = "userimagepool", file = "UserImagePool", dir = "/importexport/",   root  = 8  },
    { key = "macros",        file = "Macros",        dir = "/importexport/",   root  = 13 },
    { key = "effects",       file = "Effects",       dir = "/importexport/",   root  = 24 },
    { key = "timecodes",     file = "Timecodes",     dir = "/importexport/",   root  = 35 },
    { key = "userprofiles",  file = "UserProfiles",  dir = "/importexport/",   root  = 39 },
    { key = "users",         file = "Users",         dir = "/importexport/",   root  = 40 },
}

function M.export_cmd(pool)
    if pool.root then
        return string.format('Export Root %d "%s"/o', pool.root, pool.file)
    end
    return string.format('Export * "%s"/o', pool.file)
end

-- The import plugin has to be loadable by the OLD console, so its descriptor
-- needs that console's header. Generating it is easier than shipping one
-- descriptor per version we might ever target.
function M.plugin_descriptor(target, luafile, name)
    local maj, min, str = M.parse_version(target)
    if not maj then return nil end
    return table.concat({
        '<?xml version="1.0" encoding="utf-8"?>',
        string.format('<MA xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' ..
            ' xmlns="http://schemas.malighting.de/grandma2/xml/MA"' ..
            ' xsi:schemaLocation="http://schemas.malighting.de/grandma2/xml/MA' ..
            ' http://schemas.malighting.de/grandma2/xml/%s/MA.xsd"' ..
            ' major_vers="%d" minor_vers="%d" stream_vers="%d">', target, maj, min, str),
        string.format('\t<Plugin index="0" execute_on_load="0" name="%s" luafile="%s" />',
            name, luafile),
        '</MA>',
        '',
    }, "\n")
end
```

- [x] **Step 4: Run test to verify it passes**

Run: `lua tests/downgrade-export/test_logic.lua`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add "plugins/downgrade-export/Downgrade Export.lua" tests/downgrade-export/test_logic.lua
git commit -m "feat(downgrade-export): add the pool table and command builders"
```

---

### Task 5: Downgrade Export console half

**Files:**
- Modify: `plugins/downgrade-export/Downgrade Export.lua`
- Create: `plugins/downgrade-export/Downgrade Export.xml`

**Interfaces:**
- Consumes: everything from Tasks 1–4
- Produces: `Start`, `Cleanup`

No unit test: this half is all `gma.*` calls, which cannot run off-console. It is
covered by Task 9. The pure logic it calls is already tested.

- [x] **Step 1: Write the console half**

Sequence inside `Start()`:
1. `gma.show.getvar("path")` → base; abort with a msgbox if nil.
2. `M.normalize_version(gma.show.getvar("VERSION"))` → current.
3. `gma.textinput("Target (lower) version", "3.3.4")`; validate with
   `M.parse_version`; reject unless `M.version_lt(target, current)`.
4. `M.sibling_path(base, target)` → out_base. For each of `M.SEARCH_DIRS`,
   `os.execute('mkdir "' .. windows_path .. '"')` then probe-write a temp file;
   abort naming the failing path if the probe fails.
5. One `gma.gui.confirm` stating that the run enters the setup tree and may
   interrupt DMX output, and that it should be run offline.
6. `gma.cmd("SelectDrive 1")`. Walk `M.POOLS`: for a `setup` pool, `ChangeDest 10`
   then `ChangeDest <setup>`, export, `ChangeDest /`; for a `root` pool, export
   directly. Group the two setup pools into a single `ChangeDest 10` entry.
7. After each export, poll every 1 s up to 60 s: read each `M.candidates(pool.file)`
   path until one returns content satisfying `M.is_complete`. Record the folder
   it was found in, or the timeout.
8. `M.rewrite_header(content, target)`; write the result to
   `out_base .. found_dir .. pool.file .. ".xml"`. Originals untouched.
9. Copy `base .. "/plugins/Downgrade Import.lua"` to
   `out_base .. "/plugins/Downgrade Import.lua"` verbatim, and write
   `M.plugin_descriptor(target, "Downgrade Import.lua", "Downgrade Import")`
   beside it. If the source is missing, say so rather than failing the run.
10. Report every pool's outcome via `gma.echo`, plus the two known losses
    (layouts inside views, preset default values) and a final `gma.gui.msgbox`.

- [x] **Step 2: Write the XML descriptor**

```xml
<?xml version="1.0" encoding="utf-8"?>
<MA xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.malighting.de/grandma2/xml/MA" xsi:schemaLocation="http://schemas.malighting.de/grandma2/xml/MA http://schemas.malighting.de/grandma2/xml/3.9.60/MA.xsd" major_vers="3" minor_vers="9" stream_vers="60">
	<Plugin index="0" execute_on_load="0" name="Downgrade Export" luafile="Downgrade Export.lua" />
</MA>
```

- [x] **Step 3: Verify the pure tests still pass and the file parses**

Run: `luac -p "plugins/downgrade-export/Downgrade Export.lua" && lua tests/downgrade-export/test_logic.lua`
Expected: no syntax error, tests PASS

- [ ] **Step 4: Commit**

```bash
git add plugins/downgrade-export/
git commit -m "feat(downgrade-export): add the console entry point and descriptor"
```

---

### Task 6: Downgrade Import pure logic

**Files:**
- Create: `plugins/downgrade-import/Downgrade Import.lua`
- Create: `tests/downgrade-import/test_logic.lua`

**Interfaces:**
- Produces: `M.IMPORT_ORDER`, `M.import_cmd(pool) -> string`, `M.layer_key(name, count) -> string`, `M.find_scratch(before, after) -> entry | nil, reason`, `M.settled(prev, now) -> bool`

- [x] **Step 1: Write the failing test**

```lua
local PLUGIN = "plugins/downgrade-import/Downgrade Import.lua"
local M = assert(loadfile(PLUGIN))()

-- Import order carries dependencies: groups and presets before the sequences
-- that reference them, layouts before anything that points at one.
eq(#M.IMPORT_ORDER, 13, "same thirteen pools")
eq(M.IMPORT_ORDER[1].key, "fixturetype", "fixture types first")
eq(M.IMPORT_ORDER[2].key, "fixturelayers", "layers second")
eq(M.IMPORT_ORDER[#M.IMPORT_ORDER].key, "users", "users last")
eq(M.IMPORT_ORDER[#M.IMPORT_ORDER - 1].key, "userprofiles", "profiles second to last")

local by_key = {}
for i, p in ipairs(M.IMPORT_ORDER) do by_key[p.key] = { pool = p, at = i } end
eq(by_key.groups.at < by_key.sequence.at, true, "groups before sequences")
eq(by_key.presets.at < by_key.sequence.at, true, "presets before sequences")
eq(by_key.sequence.at < by_key.executorpages.at, true, "sequences before pages")

eq(M.import_cmd(by_key.macros.pool), 'Import "Macros" At Root 13', "root import")
eq(M.import_cmd(M.IMPORT_ORDER[2]), 'Import "FixtureLayers" At 2/o', "layers import")

-- Identity, not position. The layer list renumbers across an import, so the
-- scratch layer is found by what it is, never by the number it had.
eq(M.layer_key("test", 1), "test|1", "key from name and fixture count")
eq(M.layer_key(nil, 1), "?|1", "missing name tolerated")

local before = { { key = "test|1", number = 2 } }
local after = {
    { key = "(GZ) LED|36", number = 2 },
    { key = "(GZ) BEAM|22", number = 3 },
    { key = "test|1", number = 28 },
}
local found = M.find_scratch(before, after)
eq(found.number, 28, "scratch layer found at its NEW number")
eq(found.key, "test|1", "scratch layer identified by key")

-- If the import happened to reuse the scratch layer's identity, deleting is not
-- safe, so refuse rather than guess.
local ambiguous = { { key = "test|1", number = 2 }, { key = "test|1", number = 9 } }
eq(M.find_scratch(before, ambiguous), nil, "two matches is a refusal")
eq(M.find_scratch(before, { { key = "(GZ) LED|36", number = 2 } }), nil,
   "scratch layer already gone is a refusal")
eq(M.find_scratch({}, after), nil, "nothing recorded beforehand is a refusal")

-- amount over-reports pool collections by one, so absolute values mean nothing;
-- only two identical consecutive reads do.
eq(M.settled(nil, 5), false, "first sample is never settled")
eq(M.settled(4, 5), false, "still growing")
eq(M.settled(5, 5), true, "two equal reads means settled")
```

- [x] **Step 2: Run test to verify it fails**

Run: `lua tests/downgrade-import/test_logic.lua`
Expected: FAIL — the plugin file does not exist yet.

- [x] **Step 3: Write minimal implementation**

```lua
local M = {}

M.IMPORT_ORDER = {
    { key = "fixturetype",   file = "FixtureType",   setup = 3 },
    { key = "fixturelayers", file = "FixtureLayers", setup = 4, at = 2 },
    { key = "userimagepool", file = "UserImagePool", root = 8  },
    { key = "effects",       file = "Effects",       root = 24 },
    { key = "groups",        file = "Groups",        root = 22 },
    { key = "layouts",       file = "Layouts",       root = 38 },
    { key = "presets",       file = "Presets",       root = 17 },
    { key = "sequence",      file = "Sequence",      root = 25 },
    { key = "executorpages", file = "ExecutorPages", root = 30 },
    { key = "timecodes",     file = "Timecodes",     root = 35 },
    { key = "macros",        file = "Macros",        root = 13 },
    { key = "userprofiles",  file = "UserProfiles",  root = 39 },
    { key = "users",         file = "Users",         root = 40 },
}

function M.import_cmd(pool)
    if pool.root then
        return string.format('Import "%s" At Root %d', pool.file, pool.root)
    end
    -- Fixture layers land at number 2 because layer numbering starts at 2:
    -- there is no layer 1 on this console.
    return string.format('Import "%s" At %d/o', pool.file, pool.at or 2)
end

function M.layer_key(name, count)
    return string.format("%s|%d", name and tostring(name) or "?", tonumber(count) or -1)
end

-- The old macro hardcoded "Delete 2" for the scratch layer. That is only correct
-- if the import leaves numbering alone, which was never established. Matching on
-- identity is correct either way: whatever the scratch layer's number is now,
-- that is what gets deleted.
function M.find_scratch(before, after)
    if type(before) ~= "table" or type(after) ~= "table" or #before == 0 then
        return nil, "no layer list was recorded before the import"
    end
    local wanted = {}
    for _, e in ipairs(before) do wanted[e.key] = true end

    local hits = {}
    for _, e in ipairs(after) do
        if wanted[e.key] then hits[#hits + 1] = e end
    end
    if #hits == 1 then return hits[1] end
    if #hits == 0 then
        return nil, "the pre-import layer is gone; the import replaced it"
    end
    return nil, string.format("%d layers match the pre-import one; refusing to guess", #hits)
end

-- gma.show.getobj.amount over-reports a pool collection by one, so the absolute
-- number is not trustworthy. Two identical consecutive reads are.
function M.settled(prev, now)
    return prev ~= nil and prev == now
end
```

- [x] **Step 4: Run test to verify it passes**

Run: `lua tests/downgrade-import/test_logic.lua`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add "plugins/downgrade-import/Downgrade Import.lua" tests/downgrade-import/test_logic.lua
git commit -m "feat(downgrade-import): add import order and scratch-layer identification"
```

---

### Task 7: Downgrade Import console half

**Files:**
- Modify: `plugins/downgrade-import/Downgrade Import.lua`
- Create: `plugins/downgrade-import/Downgrade Import.xml`

**Interfaces:**
- Consumes: everything from Task 6
- Produces: `Start`, `Cleanup`

Must stay Lua 5.1-compatible: this half loads on 3.3.4. No goto, no integer
division, no `table.unpack`. Every `gma.*` call goes through the `call1` pcall
wrapper so a missing function on an old console degrades instead of erroring.

- [x] **Step 1: Write the console half**

Sequence inside `Start()`:
1. `gma.gui.confirm` warning that this should be a new, empty show and that the
   run modifies the patch; abort on cancel.
2. Read the layer list: `gma.show.getobj.handle("Root 10")`, walk children for
   `class == "CMD_FIXTURE_LAYER_COLLECT"`, then list its children. Because
   `amount` over-reports by one, stop at the first index that returns no handle.
   Build `before` as `{ key = M.layer_key(name, amount), number = number }`.
3. If `before` is empty, stop and tell the user to patch a scratch dimmer first
   (Channel ID 34567, DMX 234.56) — the import needs a layer to exist.
4. `gma.cmd("SelectDrive 1")`, then walk `M.IMPORT_ORDER`. For a `root` pool:
   read the destination pool's `amount`, run `M.import_cmd(pool)`, then poll
   `amount` once a second until `M.settled(prev, now)` or 120 s. For a `setup`
   pool: `ChangeDest 10`, `ChangeDest <setup>`, import, `ChangeDest /`.
5. Re-read the layer list into `after`. `M.find_scratch(before, after)`; on a hit,
   `ChangeDest 10`, `ChangeDest 4`, `Delete <number>`, `ChangeDest /`. On a
   refusal, report the reason and leave the layer alone.
6. Report every pool and whether the scratch layer was removed.

- [x] **Step 2: Write the XML descriptor**

Ship a 3.9.60-headed descriptor for the repo (so the plugin can be installed on
the high version for Task 5 step 9 to copy). The low-version descriptor is
generated at runtime by `M.plugin_descriptor`, not committed.

```xml
<?xml version="1.0" encoding="utf-8"?>
<MA xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.malighting.de/grandma2/xml/MA" xsi:schemaLocation="http://schemas.malighting.de/grandma2/xml/MA http://schemas.malighting.de/grandma2/xml/3.9.60/MA.xsd" major_vers="3" minor_vers="9" stream_vers="60">
	<Plugin index="0" execute_on_load="0" name="Downgrade Import" luafile="Downgrade Import.lua" />
</MA>
```

- [x] **Step 3: Verify the file parses and tests still pass**

Run: `luac -p "plugins/downgrade-import/Downgrade Import.lua" && lua tests/downgrade-import/test_logic.lua`
Expected: no syntax error, tests PASS

- [ ] **Step 4: Commit**

```bash
git add plugins/downgrade-import/
git commit -m "feat(downgrade-import): add the console entry point and descriptor"
```

---

### Task 8: Documentation and probe cleanup

**Files:**
- Modify: `README.md`
- Create: `plugins/downgrade-export/README.md`
- Move: `plugins/downgrade-probe/` -> `sandbox/downgrade-probe/`

**Interfaces:** none

- [x] **Step 1: Add both plugins to the repo README**

Add to the features list, matching the existing entry style (a bolded plugin name
followed by an em-dash and a paragraph). State plainly that this pair is for two
onPC installs on one machine, and that the macros in `gma2-macros` remain the
route for two separate consoles.

- [x] **Step 2: Write the plugin README**

Covering: the two-step workflow, the requirement that both onPC versions are
installed on the same machine, that the low version must be launched once before
the first run so its folders exist, that the run should be offline, that a
scratch dimmer must be patched in the target show, and the two known losses.

- [x] **Step 3: Move the probe out of the release path**

```bash
mkdir -p sandbox/downgrade-probe
mv plugins/downgrade-probe/* sandbox/downgrade-probe/
rmdir plugins/downgrade-probe
```

Not deleted, as originally planned: `scripts/build-release.sh` packages every
folder under `plugins/`, so the probe would ship in a release from there — but it
is still the tool that reads the layer list for the Task 9 comparison. `sandbox/`
is the repo's home for exactly this, and is not packaged. Delete it after Task 9
passes.

- [ ] **Step 4: Commit**

```bash
git add README.md plugins/downgrade-export/README.md
git commit -m "docs(downgrade): document the plugin pair and drop the probe"
```

---

### Task 9: Console acceptance

**Files:** none

**Interfaces:** none

This is the user's to run; it cannot be done on this machine.

- [ ] **Step 1: Control run**

Downgrade the source show with the three original macros from `gma2-macros`.
Record, in the resulting 3.3.4 show: sequence count, preset count, group count,
layer count and layer names, and whether `(GZ) LED` (the layer that would sit at
number 2) survived. That last one finally answers whether the old `Delete 2`
destroys data.

- [ ] **Step 2: Plugin run**

Starting from the same source show and a fresh 3.3.4 show with a scratch dimmer,
run `Downgrade Export` then `Downgrade Import`. Record the same figures.

- [ ] **Step 3: Compare**

Differences between the two runs are plugin bugs. Content missing from *both*
runs is inherent to downgrading and belongs in the README's known-losses list,
not in the bug list.

- [ ] **Step 4: Record the result**

Append the outcome to the spec under a "Verified on console" heading, including
the answer to the `Delete 2` question, then commit.
