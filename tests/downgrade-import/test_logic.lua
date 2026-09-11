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

-- ─── layer_key ────────────────────────────────────────────────

eq(M.layer_key("test", 1), "test|1", "key from name and fixture count")
eq(M.layer_key("(GZ) LED 2", 36), "(GZ) LED 2|36", "name may contain spaces and digits")
eq(M.layer_key(nil, 1), "?|1", "missing name tolerated")
eq(M.layer_key("test", nil), "test|-1", "missing count tolerated")

-- ─── find_scratch ─────────────────────────────────────────────

local before = { { key = "test|1", number = 2 } }

-- The realistic case: importing renumbers, and the scratch layer moves.
local after = {
    { key = "(GZ) LED 2|36", number = 2 },
    { key = "(GZ) BEAM 3|22", number = 3 },
    { key = "test|1", number = 28 },
}
local found = M.find_scratch(before, after)
eq(found ~= nil, true, "scratch layer found")
eq(found.number, 28, "found at its NEW number, not the one it started with")
eq(found.key, "test|1", "identified by key")

-- The other possible outcome: numbering is untouched and it is still at 2.
local unchanged = { { key = "test|1", number = 2 }, { key = "(GZ) LED 2|36", number = 3 } }
eq(M.find_scratch(before, unchanged).number, 2, "works when numbering did not move")

-- Refusals. Deleting the wrong layer costs a production layer, so anything
-- ambiguous stops rather than guesses.
local ambiguous = { { key = "test|1", number = 2 }, { key = "test|1", number = 9 } }
eq(M.find_scratch(before, ambiguous), nil, "two identical matches is a refusal")
eq(M.find_scratch(before, { { key = "(GZ) LED 2|36", number = 2 } }), nil,
   "scratch layer already gone is a refusal")
eq(M.find_scratch({}, after), nil, "nothing recorded beforehand is a refusal")
eq(M.find_scratch(nil, after), nil, "nil before is a refusal")
eq(M.find_scratch(before, nil), nil, "nil after is a refusal")

local _, why = M.find_scratch(before, ambiguous)
eq(type(why), "string", "a refusal explains itself")

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
