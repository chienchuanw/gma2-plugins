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

for _, p in ipairs(M.POOLS) do
    ok(p.key ~= "fixture" and p.key ~= "dmx" and p.key ~= "patch",
       "no destructive patch pool: " .. p.key)
end

-- ── prompt_text: count when known, yes/no/cancel hint always ──
eq(M.prompt_text("macros", 14), "Delete all 14 macros?  (yes / no / cancel)", "prompt with count")
eq(M.prompt_text("presets"), "Delete all presets?  (yes / no / cancel)", "prompt without count")

-- ── parse_answer: yes → select, no/blank → skip, cancel/nil → abort ──
eq(M.parse_answer("yes"), "select", "yes selects")
eq(M.parse_answer("Yes"), "select", "case-insensitive yes")
eq(M.parse_answer("  y "), "select", "trimmed y selects")
eq(M.parse_answer("no"), "skip", "no skips this pool")
eq(M.parse_answer(""), "skip", "blank (Enter on cleared field) skips")
eq(M.parse_answer("maybe"), "skip", "any other text skips")
eq(M.parse_answer("cancel"), "abort", "cancel aborts whole plugin")
eq(M.parse_answer("C"), "abort", "c aborts")
eq(M.parse_answer(nil), "abort", "dialog Cancel button (nil) aborts")

-- ── delete_commands: one 'Thru /nc' per normal pool ──
local mac = M.delete_commands(M.POOLS[1])
eq(#mac, 1, "macro → one command")
eq(mac[1], "Delete Macro Thru /nc", "macro delete command")
eq(M.delete_commands(M.POOLS[3])[1], "Delete Group Thru /nc", "group delete command")

-- ── delete_commands: presets fan out per feature type ──
local pre = M.delete_commands(M.POOLS[2])
eq(#pre, 9, "preset → one command per feature type (1..9)")
eq(pre[1], "Delete Preset 1.* /nc", "preset type 1 command")
eq(pre[4], "Delete Preset 4.* /nc", "preset type 4 (Color) command")
eq(pre[9], "Delete Preset 9.* /nc", "preset type 9 (Video) command")

-- ── summary_text / confirm_text: show count when present, label-only when nil ──
eq(M.summary_text({ { label = "macros", count = 14 }, { label = "effects", count = 3 } }),
   "Cleaned: macros (14), effects (3)", "summary with counts")
eq(M.summary_text({ { label = "pages" } }), "Cleaned: pages", "summary without count")
eq(M.summary_text({}), "Cleaned: nothing.", "empty summary")

eq(M.confirm_text({ { label = "macros", count = 14 }, { label = "pages" } }),
   "About to delete:\n  macros (14)\n  pages\n\nProceed?",
   "final confirm mixes counted and uncounted pools")

if fails == 0 then
    print("ALL TESTS PASSED")
else
    print(fails .. " TEST(S) FAILED")
    os.exit(1)
end
