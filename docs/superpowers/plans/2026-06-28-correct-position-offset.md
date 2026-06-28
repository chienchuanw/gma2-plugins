# Correct Position Offset Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a first-party grandMA2 plugin that bakes the difference between two Position presets into each fixture instance's Pan/Tilt offset, correctly handling multi-instance fixtures (`.1 .3 .5 .7 .9`).

**Architecture:** Single self-contained Lua file (the console loads only one luafile, no `require`). Pure logic (XML parse, delta computation, target/format helpers) is gma-free and unit-tested with a standalone `lua` interpreter; gma-bound glue (export, property read, assign, dialogs) is syntax-gated with `luac -p` and verified manually on-console. The plugin reuses the proven Export→poll-read→parse pattern from `Update Info`.

**Tech Stack:** Lua (grandMA2 console runtime ≈ Lua 5.2; local tests run on Lua 5.5), grandMA2 `gma.*` API, MA XML showfile format.

## Global Constraints

- Target console **grandMA2 3.9.60**; XML descriptor schema must match (copy from an existing first-party `.xml`).
- **Single-file plugin** — no `require`, no second Lua file loaded by the console.
- Console Lua is ~5.2: avoid 5.3+/5.5-only syntax. Stick to `string`/`table`/`tonumber`/`pcall`/`io`/`os` basics used by existing plugins.
- Plugin **must `return Start, Cleanup`** when running in the console (i.e. when global `gma` exists).
- **UI text English; code comments Traditional Chinese (zh-TW).**
- Plugin display name **"Correct Position Offset"**; files `plugins/correct-position-offset/Correct Position Offset.lua` + `.xml`.
- Accumulate semantics: `new_offset = current_offset + (corrected − original)`.
- Position presets only (`Preset 2.x`); attributes only `PAN`/`TILT`.
- Instance suffix from `subfixture_id` (absent ⇒ `1`); write to exact sub-fixture.
- **No co-author / tool-attribution trailers in commit messages** (project rule).
- Test files live under `tests/` (repo root), **never** inside `plugins/<name>/` (would be packaged into the release zip by `scripts/build-release.sh`).
- Cannot run the console from this machine — gma-dependent behaviour is verified by a manual on-console checklist, not fabricated test commands.

---

## File Structure

- Create `plugins/correct-position-offset/Correct Position Offset.lua` — the plugin (config, pure helpers, gma glue, `Start`/`Cleanup`).
- Create `plugins/correct-position-offset/Correct Position Offset.xml` — 3.9.60 descriptor.
- Create `tests/correct-position-offset/test_logic.lua` — pure-logic unit tests, run with `lua`.
- Modify `README.md` — feature list, download links, usage, structure tree.

---

## Task 1: Pure logic (parse, deltas, helpers) — TDD with real `lua` tests

**Files:**
- Create: `plugins/correct-position-offset/Correct Position Offset.lua` (pure portion + test-export tail)
- Test: `tests/correct-position-offset/test_logic.lua`

**Interfaces:**
- Produces (exposed via the file's test-export tail when global `gma` is nil):
  - `parse_preset(xml: string) -> { pan = {[key]=number}, tilt = {[key]=number} }` where `key = "<idtype>:<id>.<sub>"`, `idtype ∈ "fixt"|"chan"`.
  - `build_deltas(orig, corr, cfg) -> { {target=string, pan=number?, tilt=number?}, ... }` sorted by target; one entry per instance key present in BOTH presets for at least one enabled attribute. `cfg = {OFFSET_PAN=bool, OFFSET_TILT=bool}`.
  - `offset_target(idtype: string, id: string, sub: string) -> string` e.g. `"Fixture 201.3"`, `"Channel 5.1"`.
  - `fmt(n: number) -> string` — `"%.3f"`.

- [ ] **Step 1: Write the failing test**

Create `tests/correct-position-offset/test_logic.lua`:

```lua
-- run from repo root:  lua tests/correct-position-offset/test_logic.lua
local PLUGIN = "plugins/correct-position-offset/Correct Position Offset.lua"
local M = assert(loadfile(PLUGIN))()   -- global gma is nil here → returns pure-export table

local fails = 0
local function eq(a, b, msg)
    if a ~= b then
        fails = fails + 1
        print(string.format("FAIL: %s (expected %s, got %s)", msg, tostring(b), tostring(a)))
    end
end

local ORIG = [[
<MA>
<PresetValue Value="-30.0"><Channel fixture_id="201" attribute_name="PAN" /></PresetValue>
<PresetValue Value="-80.0"><Channel fixture_id="201" attribute_name="TILT" /></PresetValue>
<PresetValue Value="-20.0"><Channel fixture_id="201" subfixture_id="3" attribute_name="PAN" /></PresetValue>
<PresetValue Value="-10.0"><Channel fixture_id="202" attribute_name="PAN" /></PresetValue>
</MA>]]

local CORR = [[
<MA>
<PresetValue Value="-25.0"><Channel fixture_id="201" attribute_name="PAN" /></PresetValue>
<PresetValue Value="-78.0"><Channel fixture_id="201" attribute_name="TILT" /></PresetValue>
<PresetValue Value="-14.0"><Channel fixture_id="201" subfixture_id="3" attribute_name="PAN" /></PresetValue>
<PresetValue Value="-9.0"><Channel fixture_id="203" attribute_name="PAN" /></PresetValue>
</MA>]]

-- parse_preset: keys per instance, PAN/TILT separated, subfixture default 1
local p = M.parse_preset(ORIG)
eq(p.pan["fixt:201.1"], -30.0, "parse pan 201.1")
eq(p.tilt["fixt:201.1"], -80.0, "parse tilt 201.1")
eq(p.pan["fixt:201.3"], -20.0, "parse pan 201.3 subfixture")
eq(p.pan["fixt:202.1"], -10.0, "parse pan 202.1")
eq(p.tilt["fixt:201.3"], nil, "no tilt for 201.3")

-- offset_target
eq(M.offset_target("fixt", "201", "3"), "Fixture 201.3", "target fixture sub")
eq(M.offset_target("chan", "5", "1"), "Channel 5.1", "target channel")

-- fmt
eq(M.fmt(12.3456), "12.346", "fmt rounds to 3dp")
eq(M.fmt(-4), "-4.000", "fmt integer")

-- build_deltas, both axes
local d = M.build_deltas(M.parse_preset(ORIG), M.parse_preset(CORR),
                         {OFFSET_PAN = true, OFFSET_TILT = true})
local got = {}
for _, e in ipairs(d) do got[e.target] = e end
eq(got["Fixture 201.1"].pan, 5.0, "delta pan 201.1")    -- -25 - -30
eq(got["Fixture 201.1"].tilt, 2.0, "delta tilt 201.1")   -- -78 - -80
eq(got["Fixture 201.3"].pan, 6.0, "delta pan 201.3")     -- -14 - -20
eq(got["Fixture 201.3"].tilt, nil, "no tilt delta 201.3")
eq(got["Fixture 202.1"], nil, "202 only in orig → excluded")
eq(got["Fixture 203.1"], nil, "203 only in corr → excluded")
eq(#d, 2, "exactly 2 instances in intersection")

-- build_deltas, pan only
local d2 = M.build_deltas(M.parse_preset(ORIG), M.parse_preset(CORR),
                          {OFFSET_PAN = true, OFFSET_TILT = false})
local got2 = {}
for _, e in ipairs(d2) do got2[e.target] = e end
eq(got2["Fixture 201.1"].pan, 5.0, "pan-only still applies pan")
eq(got2["Fixture 201.1"].tilt, nil, "pan-only suppresses tilt")

if fails == 0 then print("ALL TESTS PASSED") else print(fails .. " FAILURE(S)"); os.exit(1) end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `lua tests/correct-position-offset/test_logic.lua`
Expected: FAIL — `cannot open plugins/correct-position-offset/Correct Position Offset.lua` (file not created yet).

- [ ] **Step 3: Write minimal implementation**

Create `plugins/correct-position-offset/Correct Position Offset.lua` with the config block, pure helpers, and the test-export tail. (gma glue is added in Task 2; the tail returns the pure table when `gma` is absent.)

```lua
-- Correct Position Offset
-- 把兩個 Position preset 的差值,累加進每顆燈「每個 instance」的 Pan/Tilt offset。
-- UI 文字英文;註解中文。目標版本:grandMA2 3.9.60
--
-- 原理:
--   Export Preset 2.<orig> / 2.<corrected> → 讀 importexport XML → 解析每個
--   <PresetValue> 的 fixture_id / subfixture_id(無=1)/ attribute_name(PAN/TILT)/ Value。
--   對兩個 preset 都出現的 instance,delta = corrected - orig;讀目前 offset 累加後
--   Assign Fixture <id>.<sub> /panoffset= /tiltoffset=。
--   instance 用 subfixture_id 區分,故 .1 .3 .5 .7 .9 全部會被校正(原版只到 .1)。

local PLUGIN_TITLE = "Correct Position Offset"

---- USER CONFIG ----
local CONFIG = {
    OFFSET_PAN  = true,   -- 套用 Pan offset
    OFFSET_TILT = true,   -- 套用 Tilt offset
}

-- 設 true 會把過程印到 System Monitor(除錯用)
local DEBUG = false

-- 匯出暫存檔名(每次覆蓋後刪除)
local TMP_NAME = "correct_position_offset_tmp"

local internal_name = select(1, ...)
local visible_name  = select(2, ...)

-- ─── 純邏輯(不依賴 gma,可離線單元測試)──────────────────────

-- attribute_name(PAN/TILT,大小寫不拘)→ "pan"/"tilt";其他屬性回 nil
local function attr_key(name)
    name = name:lower()
    if name == "pan"  then return "pan"  end
    if name == "tilt" then return "tilt" end
    return nil
end

-- 把一份 preset XML 解析成 { pan = {[key]=value}, tilt = {[key]=value} }
-- key = "<idtype>:<id>.<sub>",idtype = fixt|chan,sub 預設 1。
local function parse_preset(xml)
    local out = { pan = {}, tilt = {} }
    for block in xml:gmatch("<PresetValue.-</PresetValue>") do
        local value = tonumber(block:match('PresetValue Value="([%-%d%.]+)"'))
        local attr  = block:match('attribute_name="([^"]+)"')
        local ak    = attr and attr_key(attr) or nil
        if value and ak then
            local idtype, id = "fixt", block:match('fixture_id="([%-%d%.]+)"')
            if not id then
                idtype, id = "chan", block:match('channel_id="([%-%d%.]+)"')
            end
            local sub = block:match('subfixture_id="([%-%d%.]+)"') or "1"
            if id then
                out[ak][idtype .. ":" .. id .. "." .. sub] = value
            end
        end
    end
    return out
end

-- 由 idtype/id/sub 組出指令用的目標字串
local function offset_target(idtype, id, sub)
    local kw = (idtype == "chan") and "Channel" or "Fixture"
    return string.format("%s %s.%s", kw, id, sub)
end

-- 數字格式化(degrees,3 位小數)
local function fmt(n)
    return string.format("%.3f", n)
end

-- 取兩個 preset 的交集,算每個 instance 的 pan/tilt delta。
-- 回傳依 target 排序的清單:{ {target, pan=?, tilt=?}, ... }
local function build_deltas(orig, corr, cfg)
    local attrs = {}
    if cfg.OFFSET_PAN  then attrs[#attrs + 1] = "pan"  end
    if cfg.OFFSET_TILT then attrs[#attrs + 1] = "tilt" end

    local byKey, keys = {}, {}
    for _, a in ipairs(attrs) do
        for key, cval in pairs(corr[a]) do
            local oval = orig[a][key]
            if oval ~= nil then
                local e = byKey[key]
                if not e then e = {}; byKey[key] = e; keys[#keys + 1] = key end
                e[a] = cval - oval
            end
        end
    end

    table.sort(keys)  -- 穩定輸出順序,方便測試與閱讀
    local list = {}
    for _, key in ipairs(keys) do
        local idtype, id, sub = key:match("^(%a+):(%-?%d+)%.(%-?%d+)$")
        list[#list + 1] = {
            target = offset_target(idtype, id, sub),
            pan    = byKey[key].pan,
            tilt   = byKey[key].tilt,
        }
    end
    return list
end

-- ─── 測試匯出 / 主控台進入點 ──────────────────────────────────
-- 在主控台執行時 gma 全域存在 → 回傳 Start, Cleanup。
-- 離線(本機 lua 測試)時 gma 為 nil → 匯出純函式供測試。
if gma then
    return Start, Cleanup
else
    return {
        parse_preset  = parse_preset,
        build_deltas  = build_deltas,
        offset_target = offset_target,
        fmt           = fmt,
    }
end
```

- [ ] **Step 4: Run test to verify it passes**

Run: `lua tests/correct-position-offset/test_logic.lua`
Expected: `ALL TESTS PASSED`

- [ ] **Step 5: Syntax-gate the plugin for the console runtime**

Run: `luac -p "plugins/correct-position-offset/Correct Position Offset.lua"`
Expected: no output (exit 0).

- [ ] **Step 6: Commit**

```bash
git add "plugins/correct-position-offset/Correct Position Offset.lua" tests/correct-position-offset/test_logic.lua
git commit -m "feat(correct-position-offset): pure preset-diff logic + tests"
```

---

## Task 2: gma glue + Start/Cleanup + XML descriptor

**Files:**
- Modify: `plugins/correct-position-offset/Correct Position Offset.lua` (insert gma-bound functions and `Start`/`Cleanup` before the export tail)
- Create: `plugins/correct-position-offset/Correct Position Offset.xml`

**Interfaces:**
- Consumes (from Task 1, as upvalues in the same file): `parse_preset`, `build_deltas`, `fmt`.
- Produces: console entry points `Start()` and `Cleanup()` (globals), returned as `return Start, Cleanup` when `gma` exists.

- [ ] **Step 1: Insert the gma-bound functions and entry points**

In `Correct Position Offset.lua`, between the `build_deltas` definition and the `-- ─── 測試匯出` tail comment, insert:

```lua
-- ─── gma 介接(需主控台,無法離線測試)────────────────────────

-- Export 指定 position preset 並讀回 XML(沿用 Update Info 的輪詢+</MA> 偵測)。
-- 失敗回 nil。
local function export_and_read(preset_no)
    local base = gma.show.getvar("path") or gma.show.getvar("PATH")
    if not base then return nil end
    local full = base .. "/importexport/" .. TMP_NAME .. ".xml"

    gma.cmd("SelectDrive 1")          -- 確保 Export 與讀檔路徑一致(內建碟)
    os.remove(full)
    gma.cmd(string.format('Export Preset 2.%s "%s" /nc', tostring(preset_no), TMP_NAME))

    local xml
    for _ = 1, 40 do                   -- gma.cmd 為非同步,輪詢等檔寫完(最多約 2 秒)
        gma.sleep(0.05)
        local f = io.open(full, "r")
        if f then
            local c = f:read("*a"); f:close()
            if c and c:find("</MA>", 1, true) then xml = c; break end
        end
    end
    os.remove(full)
    return xml
end

-- 讀某 instance 目前的 offset(prop = "panoffset"/"tiltoffset")。讀不到回 0。
local function read_offset(target, prop)
    local h = gma.show.getobj.handle(target)
    if not h then return 0 end
    local ok, v = pcall(gma.show.property.get, h, prop)
    local n = ok and tonumber(v) or nil
    if (not n) and DEBUG then
        gma.echo(string.format("[%s] could not read %s of %s → using 0", PLUGIN_TITLE, prop, target))
    end
    return n or 0
end

-- 對每個 instance 累加 delta 並送出 Assign。回傳統計。
local function apply_offsets(deltas)
    local counts = { pan = 0, tilt = 0, instances = 0 }
    for _, e in ipairs(deltas) do
        local parts = {}
        if e.pan then
            parts[#parts + 1] = "/panoffset=" .. fmt(read_offset(e.target, "panoffset") + e.pan)
            counts.pan = counts.pan + 1
        end
        if e.tilt then
            parts[#parts + 1] = "/tiltoffset=" .. fmt(read_offset(e.target, "tiltoffset") + e.tilt)
            counts.tilt = counts.tilt + 1
        end
        if #parts > 0 then
            gma.cmd(string.format("Assign %s %s", e.target, table.concat(parts, " ")))
            counts.instances = counts.instances + 1
            if DEBUG then
                gma.echo(string.format("[%s] %s %s", PLUGIN_TITLE, e.target, table.concat(parts, " ")))
            end
        end
    end
    return counts
end

-- ─── 進入點 ───────────────────────────────────────────────────

function Start()
    if not (CONFIG.OFFSET_PAN or CONFIG.OFFSET_TILT) then
        gma.gui.msgbox(PLUGIN_TITLE,
            "Both Pan and Tilt are disabled.\n\nEnable at least one in the CONFIG block, then run again.")
        return
    end

    local orig_no = gma.textinput("Original position preset number?", "1")
    if orig_no == nil then gma.feedback(PLUGIN_TITLE .. ": cancelled."); return end
    local corr_no = gma.textinput("Corrected position preset number?", "1")
    if corr_no == nil then gma.feedback(PLUGIN_TITLE .. ": cancelled."); return end
    orig_no = orig_no:gsub("%s+", "")
    corr_no = corr_no:gsub("%s+", "")

    local O = gma.show.getobj
    if not O.handle("Preset 2." .. orig_no) then
        gma.gui.msgbox(PLUGIN_TITLE, "Position preset 2." .. orig_no .. " does not exist."); return
    end
    if not O.handle("Preset 2." .. corr_no) then
        gma.gui.msgbox(PLUGIN_TITLE, "Position preset 2." .. corr_no .. " does not exist."); return
    end

    local oxml = export_and_read(orig_no)
    local cxml = export_and_read(corr_no)
    if not oxml or not cxml then
        gma.gui.msgbox(PLUGIN_TITLE,
            "Failed to export/read a preset (export error).\n\nSet DEBUG=true for details.")
        return
    end

    local deltas = build_deltas(parse_preset(oxml), parse_preset(cxml), CONFIG)
    if #deltas == 0 then
        gma.gui.msgbox(PLUGIN_TITLE,
            "No fixture instances appear in both presets.\n\nNothing to apply.")
        return
    end

    local c = apply_offsets(deltas)

    gma.gui.msgbox(PLUGIN_TITLE, string.format(
        "Done.\n\nOriginal preset: 2.%s\nCorrected preset: 2.%s\n" ..
        "Instances offset: %d\nPan: %d   Tilt: %d",
        orig_no, corr_no, c.instances, c.pan, c.tilt))
    gma.feedback(string.format("%s: %d instance(s) (Pan %d, Tilt %d) from 2.%s -> 2.%s",
        PLUGIN_TITLE, c.instances, c.pan, c.tilt, orig_no, corr_no))
end

function Cleanup()
end
```

- [ ] **Step 2: Verify pure tests still pass (no regression)**

Run: `lua tests/correct-position-offset/test_logic.lua`
Expected: `ALL TESTS PASSED` (the test tail still returns the pure table because `gma` is nil offline; `Start`/`Cleanup` are defined but unused).

- [ ] **Step 3: Syntax-gate the full plugin**

Run: `luac -p "plugins/correct-position-offset/Correct Position Offset.lua"`
Expected: no output (exit 0).

- [ ] **Step 4: Create the XML descriptor**

Create `plugins/correct-position-offset/Correct Position Offset.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<MA xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.malighting.de/grandma2/xml/MA" xsi:schemaLocation="http://schemas.malighting.de/grandma2/xml/MA http://schemas.malighting.de/grandma2/xml/3.9.60/MA.xsd" major_vers="3" minor_vers="9" stream_vers="60">
	<Plugin index="0" execute_on_load="0" name="Correct Position Offset" luafile="Correct Position Offset.lua" />
</MA>
```

- [ ] **Step 5: Commit**

```bash
git add "plugins/correct-position-offset/Correct Position Offset.lua" "plugins/correct-position-offset/Correct Position Offset.xml"
git commit -m "feat(correct-position-offset): add console glue, Start/Cleanup, XML"
```

- [ ] **Step 6: Manual on-console verification (record results; do NOT fabricate)**

Cannot run from this machine. On grandMA2 onPC/console (3.9.60), verify:
1. Import the `.xml`; the plugin appears and runs.
2. With two real Position presets (e.g. a TB5 rig), run it; enter the two preset numbers.
3. Confirm offsets change on **all** instances `.1 .3 .5 .7 .9`, not just `.1`.
4. Confirm values **accumulate** (run twice → offset doubles relative to a single run's delta).
5. **Verify the offset property name:** if offsets don't change, set `DEBUG=true`, re-run, and read System Monitor. If it logs "could not read panoffset", inspect the readable property names (temporary: `gma.echo(gma.show.property.name(h, i))` loop, or check the Assign that works) and update the `"panoffset"`/`"tiltoffset"` strings in `read_offset`/`apply_offsets`. Re-test.
6. Guards: non-existent preset → msgbox; Cancel on input → no change; presets with no common fixtures → "Nothing to apply".

---

## Task 3: README + release packaging

**Files:**
- Modify: `README.md` (four spots)

**Interfaces:** none (documentation + packaging only).

- [ ] **Step 1: Add to the feature list**

In `README.md`, after the `- **Create Punch** ...` feature bullet, add:

```markdown
- **Correct Position Offset** -- Bakes the difference between two Position presets into each fixture instance's Pan/Tilt offset. Enter an "original" and a "corrected" preset; for every fixture instance in both, it adds `corrected − original` to the current offset. Handles multi-instance fixtures (e.g. ACME Tornado TB5: `.1 .3 .5 .7 .9`), not just the first instance.
```

- [ ] **Step 2: Add the download link**

After the `- [**Create Punch** ...]` download bullet, add:

```markdown
- [**Correct Position Offset** (`correct-position-offset.zip`)](https://github.com/chienchuanw/gma2-plugins/releases/latest/download/correct-position-offset.zip)
```

- [ ] **Step 3: Extend the usage paragraph**

Append to the Usage paragraph (after the Create Punch sentence):

```markdown
 Run **Correct Position Offset** after re-focusing a rig into a corrected Position preset: enter the original and corrected preset numbers and it adds the per-instance Pan/Tilt difference into each fixture's offset, so existing cues using the original preset point correctly.
```

- [ ] **Step 4: Add to the structure tree**

In the `plugins/` block of the Project Structure tree, change the `create-punch/` line to keep it and add below it:

```text
│   ├── create-punch/         #   Create Punch.lua + Create Punch.xml
│   └── correct-position-offset/  #  Correct Position Offset.lua + .xml
```

(Adjust the branch glyphs so `correct-position-offset/` is the last child `└──` and `create-punch/` becomes `├──`.)

- [ ] **Step 5: Verify packaging picks up the new plugin and excludes tests**

Run: `./scripts/build-release.sh && unzip -l dist/correct-position-offset.zip`
Expected: `built: dist/correct-position-offset.zip`; the archive lists exactly `Correct Position Offset.lua` and `Correct Position Offset.xml` (no test file).

- [ ] **Step 6: Confirm the test file is not inside the plugin folder**

Run: `ls plugins/correct-position-offset/`
Expected: only `Correct Position Offset.lua` and `Correct Position Offset.xml`.

- [ ] **Step 7: Commit**

```bash
git add README.md
git commit -m "docs(correct-position-offset): document the plugin in the README"
```

---

## Self-Review

**Spec coverage:**
- Accumulate semantics → `apply_offsets` (`read_offset + delta`), tested indirectly via `build_deltas` deltas; accumulation verified on-console (Task 2 Step 6.4). ✓
- Per-instance handling (subfixture_id) → `parse_preset` key includes `.sub`; tested (`parse pan 201.3 subfixture`, `delta pan 201.3`). ✓
- Pan/Tilt toggles → `build_deltas` honours `cfg`; tested (pan-only case). ✓
- Position-only / PAN-TILT filter → `attr_key`; tested implicitly (only PAN/TILT keys present). ✓
- Export→poll-read→parse → `export_and_read` (mirrors Update Info). ✓ (on-console)
- Channel vs fixture target → `offset_target`; tested (`target channel`). ✓
- Guards (both disabled / cancel / missing preset / export fail / empty intersection) → `Start`; missing-preset & empty-intersection are explicit; export-fail explicit. ✓
- Offset property name uncertainty → `read_offset` nil→0 fallback + DEBUG; Task 2 Step 6.5 resolves on-console. ✓
- Packaging + README four spots → Task 3. ✓

**Placeholder scan:** No TBD/TODO; every code step shows complete code; on-console checklist items are concrete actions, not "handle edge cases". ✓

**Type consistency:** `parse_preset` returns `{pan=,tilt=}`; `build_deltas` consumes `corr[a]`/`orig[a]` with `a ∈ {"pan","tilt"}` ✓. `build_deltas` entries `{target,pan,tilt}` consumed identically in `apply_offsets` ✓. `offset_target` / `fmt` signatures match call sites ✓. Test-export tail key names match `M.parse_preset`/`M.build_deltas`/`M.offset_target`/`M.fmt` used in tests ✓.

No issues found.
