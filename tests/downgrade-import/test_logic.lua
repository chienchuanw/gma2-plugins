-- run from repo root:  lua tests/downgrade-import/test_logic.lua
--
-- Covers the pure half of Downgrade Import. The interesting part is
-- find_scratch: the old macro hardcoded "Delete 2" to remove the scratch layer,
-- which is only correct if importing leaves layer numbering alone - something
-- never established. Matching the layer by identity is correct either way, and
-- these tests pin that behaviour down, including the cases where it must refuse.

local PLUGIN = "plugins/downgrade-import/Downgrade Import.lua"
local M = assert(loadfile(PLUGIN))()   -- global gma is nil here -> pure-export table

local fails = 0
local function eq(a, b, msg)
    if a ~= b then
        fails = fails + 1
        print(string.format("FAIL: %s (expected %s, got %s)", msg, tostring(b), tostring(a)))
    end
end

-- ─── IMPORT_ORDER ─────────────────────────────────────────────

eq(#M.IMPORT_ORDER, 13, "thirteen pools, matching the old macro")
eq(M.IMPORT_ORDER[1].key, "fixturetype", "fixture types first")
eq(M.IMPORT_ORDER[2].key, "fixturelayers", "layers second")
eq(M.IMPORT_ORDER[#M.IMPORT_ORDER].key, "users", "users last")
eq(M.IMPORT_ORDER[#M.IMPORT_ORDER - 1].key, "userprofiles", "profiles second to last")

local at = {}
for i, p in ipairs(M.IMPORT_ORDER) do at[p.key] = i end

-- Order carries dependencies: an object cannot reference one imported later.
eq(at.fixturetype < at.fixturelayers, true, "types before the layers that use them")
eq(at.groups < at.sequence, true, "groups before sequences")
eq(at.presets < at.sequence, true, "presets before sequences")
eq(at.effects < at.sequence, true, "effects before sequences")
eq(at.sequence < at.executorpages, true, "sequences before executor pages")
eq(at.userimagepool < at.layouts, true, "images before the layouts that show them")

-- The same thirteen keys the export half produces, no more and no less.
local expected = {
    fixturetype = true, fixturelayers = true, sequence = true, executorpages = true,
    groups = true, presets = true, layouts = true, userimagepool = true,
    macros = true, effects = true, timecodes = true, userprofiles = true, users = true,
}
for _, p in ipairs(M.IMPORT_ORDER) do
    eq(expected[p.key], true, p.key .. " is an expected pool")
    expected[p.key] = nil
end
eq(next(expected), nil, "every exported pool is imported")

-- ─── import_cmd ───────────────────────────────────────────────

local by_key = {}
for _, p in ipairs(M.IMPORT_ORDER) do by_key[p.key] = p end

-- /nc suppresses the import confirmation dialog. The old macro used /o, which
-- is an Export option and is not documented for Import; a plugin cannot click
-- a dialog, so the documented one is used instead.
eq(M.import_cmd(by_key.macros), 'Import "Macros" At Root 13 /nc', "root import")
eq(M.import_cmd(by_key.users), 'Import "Users" At Root 40 /nc', "users import")
eq(M.import_cmd(by_key.fixturelayers), 'Import "FixtureLayers" At 2 /nc', "layers import")
eq(M.import_cmd(by_key.fixturetype), 'Import "FixtureType" At 2 /nc', "fixture types import")

-- ─── count addressing ─────────────────────────────────────────

-- Counting through "Root <n>" is what made the first console run report every
-- pool as importing nothing: that handle reports one child whether the pool is
-- empty or full. Every Root pool must therefore carry a keyword to count by,
-- except presets, which are counted per type.
for _, p in ipairs(M.IMPORT_ORDER) do
    if p.root then
        eq(p.keyword ~= nil or p.preset == true, true,
           p.key .. " can be counted without relying on its Root handle")
    end
end
eq(by_key.macros.keyword, "Macro", "macros counted as Macro")
eq(by_key.groups.keyword, "Group", "groups counted as Group")
eq(by_key.sequence.keyword, "Sequence", "sequences counted as Sequence")
eq(by_key.executorpages.keyword, "Page", "executor pages counted as Page")
eq(by_key.presets.preset, true, "presets are counted per type")
eq(by_key.presets.keyword, nil, "presets have no single keyword")
eq(#M.PRESET_TYPES, 9, "nine preset types, matching Clean Showfile")

-- The setup pools have no Root pool to count; the console half falls back to a
-- fixed settle for them, so they must not claim a keyword.
eq(by_key.fixturetype.keyword, nil, "fixture types have no pool count")
eq(by_key.fixturelayers.keyword, nil, "fixture layers have no pool count")

-- ─── strip_number ─────────────────────────────────────────────

-- getobj.name answers the label with the object's own number appended, so the
-- raw name changes whenever the console renumbers.
eq(M.strip_number("(GZ) LED 3", 3), "(GZ) LED", "trailing number stripped")
eq(M.strip_number("test 28", 28), "test", "two-digit number stripped")
eq(M.strip_number("2 TRUSS 15", 15), "2 TRUSS", "leading digits survive")
eq(M.strip_number("Auto-Created 2", 2), "Auto-Created", "hyphenated label")
eq(M.strip_number("(GZ) LED 3", 9), "(GZ) LED 3", "only this object's own number goes")
eq(M.strip_number("Plain", nil), "Plain", "no number to strip")
eq(M.strip_number(nil, 3), "?", "nil name tolerated")

-- ─── find_leftover_layer ──────────────────────────────────────

-- Both verified console runs are encoded here. Identity matching fails on both:
-- the scratch layer came back renamed, emptied and renumbered each time.
local before = { { number = 2, name = "test", fixtures = 1 } }

-- What the plugin produced: the scratch layer emptied and renamed in place.
local plugin_run = {
    { number = 1,  name = "Auto-Created", fixtures = 21 },
    { number = 2,  name = "Auto-Created", fixtures = 0  },
    { number = 3,  name = "(GZ) LED",     fixtures = 36 },
    { number = 28, name = "YOU LI TRUSS 3", fixtures = 5 },
}
local found = M.find_leftover_layer(before, plugin_run)
eq(found ~= nil, true, "plugin run: leftover found")
eq(found.number, 2, "plugin run: the empty layer is number 2")

-- What the macros produced: the scratch layer kept its name but moved to 28.
local macro_run = {
    { number = 2,  name = "(GZ) LED", fixtures = 35 },
    { number = 27, name = "YOU LI TRUSS 3", fixtures = 4 },
    { number = 28, name = "test", fixtures = 0 },
}
eq(M.find_leftover_layer(before, macro_run).number, 28, "macro run: leftover at 28")

-- A real layer is never empty, so a non-empty list means there is nothing to do.
eq(M.find_leftover_layer(before, { { number = 2, name = "(GZ) LED", fixtures = 35 } }), nil,
   "no empty layer is a refusal, not a deletion")

-- Two empty layers could mean the source show legitimately had one. Refuse.
local two_empty = {
    { number = 2, name = "Auto-Created", fixtures = 0 },
    { number = 9, name = "Spare",        fixtures = 0 },
}
eq(M.find_leftover_layer(before, two_empty), nil, "two empty layers is a refusal")
local _, why = M.find_leftover_layer(before, two_empty)
eq(type(why) == "string" and string.find(why, "Spare", 1, true) ~= nil, true,
   "the refusal names the candidates")

eq(M.find_leftover_layer({}, plugin_run), nil, "nothing recorded beforehand is a refusal")
eq(M.find_leftover_layer(nil, plugin_run), nil, "nil before is a refusal")
eq(M.find_leftover_layer(before, nil), nil, "nil after is a refusal")

-- A fixture count that could not be read is not evidence of emptiness, and
-- must never be the reason something gets deleted.
eq(M.find_leftover_layer(before, { { number = 2, name = "x" } }), nil,
   "an unreadable fixture count is a refusal, not a deletion")
local _, why2 = M.find_leftover_layer(before, { { number = 2, name = "x" } })
eq(type(why2) == "string" and string.find(why2, "count", 1, true) ~= nil, true,
   "the refusal says the count could not be read")

-- ─── settled ──────────────────────────────────────────────────

-- getobj.amount over-reports a pool collection by one, so the absolute number
-- means nothing; two identical consecutive reads do.
eq(M.settled(nil, 5), false, "first sample is never settled")
eq(M.settled(4, 5), false, "still growing")
eq(M.settled(5, 5), true, "two equal reads means settled")
eq(M.settled(0, 0), true, "an import that brought nothing still settles")

-- ─── result ───────────────────────────────────────────────────

if fails == 0 then
    print("all downgrade-import logic tests passed")
else
    print(string.format("%d failure(s)", fails))
    os.exit(1)
end
