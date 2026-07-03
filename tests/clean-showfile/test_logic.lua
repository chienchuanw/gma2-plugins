-- run from repo root:  lua tests/clean-showfile/test_logic.lua
local PLUGIN = "plugins/clean-showfile/Clean Showfile.lua"
local M = assert(loadfile(PLUGIN))()   -- global gma is nil here → returns pure-export table

local fails = 0
local function eq(a, b, msg)
    if a ~= b then
        fails = fails + 1
        print(string.format("FAIL: %s (expected %s, got %s)", msg, tostring(b), tostring(a)))
    end
end
local function ok(cond, msg)
    if not cond then
        fails = fails + 1
        print("FAIL: " .. msg)
    end
end

-- ── POOLS: ordered, curated content pools (no Patch/Fixtures/DMX) ──
local order = {}
for i, p in ipairs(M.POOLS) do order[i] = p.key end
eq(table.concat(order, ","),
   "macro,preset,group,sequence,effect,world,filter,layout,view,timecode,page",
   "pool order")

-- excluded pools never appear
for _, p in ipairs(M.POOLS) do
    ok(p.key ~= "fixture" and p.key ~= "dmx" and p.key ~= "patch",
       "no destructive patch pool: " .. p.key)
end

-- ── prompt_text: count-bearing question ──
eq(M.prompt_text("macros", 14), "Delete all 14 macros?", "prompt with count")
eq(M.prompt_text("presets", 1), "Delete all 1 presets?", "prompt singular count still works")

-- ── classify_answer: X/close aborts, Yes selects, No skips ──
eq(M.classify_answer(nil), "abort", "closing dialog (nil) aborts whole plugin")
eq(M.classify_answer(true), "select", "Yes marks pool for deletion")
eq(M.classify_answer(false), "skip", "No skips this pool and continues")

-- ── delete_commands: one 'Thru /nc' per normal pool ──
local mac = M.delete_commands(M.POOLS[1])         -- macro
eq(#mac, 1, "macro → one command")
eq(mac[1], "Delete Macro Thru /nc", "macro delete command")

local grp = M.delete_commands(M.POOLS[3])         -- group
eq(grp[1], "Delete Group Thru /nc", "group delete command")

-- ── delete_commands: presets fan out per feature type ──
local pre = M.delete_commands(M.POOLS[2])         -- preset (special)
eq(#pre, 9, "preset → one command per feature type (1..9)")
eq(pre[1], "Delete Preset 1.* /nc", "preset type 1 command")
eq(pre[4], "Delete Preset 4.* /nc", "preset type 4 (Color) command")
eq(pre[9], "Delete Preset 9.* /nc", "preset type 9 (Video) command")

-- ── summary_text: only selected pools, with counts ──
eq(M.summary_text({ { label = "macros", count = 14 }, { label = "effects", count = 3 } }),
   "Cleaned: macros (14), effects (3)",
   "summary lists selected pools")
eq(M.summary_text({}), "Cleaned: nothing.", "empty summary")

-- ── confirm_text: final summary before the batch runs ──
eq(M.confirm_text({ { label = "macros", count = 14 }, { label = "pages", count = 2 } }),
   "About to delete:\n  macros (14)\n  pages (2)\n\nProceed?",
   "final confirm lists everything selected")

if fails == 0 then
    print("ALL TESTS PASSED")
else
    print(fails .. " TEST(S) FAILED")
    os.exit(1)
end
