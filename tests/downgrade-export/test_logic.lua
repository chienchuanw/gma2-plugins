-- run from repo root:  lua tests/downgrade-export/test_logic.lua
--
-- Covers the pure half of Downgrade Export: version handling, header rewriting,
-- sibling-tree derivation and the pool table. The console half is all gma.*
-- calls and is verified on a console instead.
--
-- fixtures/macros-3.9.60.xml is a small slice shaped exactly like a real macro
-- pool export, including the header the console writes and the </MA> terminator
-- the plugin polls for.

local PLUGIN = "plugins/downgrade-export/Downgrade Export.lua"
local M = assert(loadfile(PLUGIN))()   -- global gma is nil here -> pure-export table

local fails = 0
local function eq(a, b, msg)
    if a ~= b then
        fails = fails + 1
        print(string.format("FAIL: %s (expected %s, got %s)", msg, tostring(b), tostring(a)))
    end
end

local function slurp(path)
    local f = assert(io.open(path, "r"), "missing test fixture: " .. path)
    local c = f:read("*a")
    f:close()
    return c
end

local function has(s, needle)
    return string.find(s, needle, 1, true) ~= nil
end

local FIX = "tests/downgrade-export/fixtures/"

-- ─── parse_version / normalize_version / version_lt ───────────

local maj, min, str = M.parse_version("3.3.4")
eq(maj, 3, "major")
eq(min, 3, "minor")
eq(str, 4, "stream")

eq(M.parse_version("3.9.60"), 3, "3.9.60 major")
eq((select(3, M.parse_version("3.9.60"))), 60, "stream is 60, not 6")
eq(M.parse_version("3.9"), nil, "two components rejected")
eq(M.parse_version("3.9.60.50"), nil, "four components rejected as a target")
eq(M.parse_version("v3.9.60"), nil, "leading letter rejected")
eq(M.parse_version(""), nil, "empty rejected")
eq(M.parse_version(nil), nil, "nil rejected")
eq(M.parse_version("  3.3.4  "), 3, "surrounding space tolerated")

-- getvar("VERSION") answers four components; a header only ever carries three.
eq(M.normalize_version("3.9.60.50"), "3.9.60", "console version truncated")
eq(M.normalize_version("3.3.4.1"), "3.3.4", "low console version truncated")
eq(M.normalize_version("3.3.4"), "3.3.4", "three components pass through")
eq(M.normalize_version(nil), nil, "nil rejected")

eq(M.version_lt("3.3.4", "3.9.60"), true, "3.3.4 is lower")
eq(M.version_lt("3.9.60", "3.3.4"), false, "3.9.60 is not lower")
eq(M.version_lt("3.9.60", "3.9.60"), false, "equal is not lower")
eq(M.version_lt("3.9.6", "3.9.60"), true, "6 < 60 numerically, not as a string")
eq(M.version_lt("2.9.60", "3.3.4"), true, "major wins over minor")
eq(M.version_lt("bad", "3.3.4"), nil, "unparseable input yields nil")

-- ─── rewrite_header ───────────────────────────────────────────

local src = slurp(FIX .. "macros-3.9.60.xml")
local out, n = M.rewrite_header(src, "3.3.4")

eq(n, 4, "four header fields replaced")
eq(has(out, 'major_vers="3"'), true, "major stays 3")
eq(has(out, 'minor_vers="3"'), true, "minor becomes 3")
eq(has(out, 'stream_vers="4"'), true, "stream becomes 4")
eq(has(out, "xml/3.3.4/MA.xsd"), true, "schema url rewritten")
eq(has(out, "xml/3.9.60/MA.xsd"), false, "no 3.9.60 schema url left")

-- The XML declaration carries version="1.0". A careless pattern would eat it.
eq(has(out, '<?xml version="1.0" encoding="utf-8"?>'), true, "xml declaration untouched")
-- The namespace ends "/grandma2/xml/MA" and must not be treated as a version.
eq(has(out, 'xmlns="http://schemas.malighting.de/grandma2/xml/MA"'), true, "xmlns untouched")

eq(has(out, "<text>Macro &quot;Song Change&quot;</text>"), true, "body preserved")
eq(has(out, 'showfile="downgrade test slice"'), true, "info line preserved")
-- "3.9.60" -> "3.3.4" loses one char, stream_vers "60" -> "4" loses one more.
eq(#out - #src, -2, "only the header changed length")

eq(M.rewrite_header(src, "nonsense"), nil, "bad target rejected")
eq(M.rewrite_header(src, "3.9"), nil, "incomplete target rejected")
eq(M.rewrite_header("<MA></MA>", "3.3.4"), nil, "file without header fields rejected")
eq(M.rewrite_header(nil, "3.3.4"), nil, "nil input rejected")

-- Rewriting is idempotent in the sense that a second pass to the same version
-- is a no-op that still reports four matches.
local twice = M.rewrite_header(out, "3.3.4")
eq(twice, out, "rewriting to the same version changes nothing")

-- ─── is_complete ──────────────────────────────────────────────

eq(M.is_complete(src), true, "fixture ends with </MA>")
eq(M.is_complete("<MA>\n</MA>\n"), true, "trailing newline allowed")
eq(M.is_complete("<MA>\n</MA>"), true, "no trailing newline allowed")
eq(M.is_complete("<MA><Macro"), false, "truncated export detected")
eq(M.is_complete("</MA> trailing junk"), false, "terminator must be last")
eq(M.is_complete(""), false, "empty file is not complete")
eq(M.is_complete(nil), false, "nil is not complete")

-- ─── sibling_path / candidates ────────────────────────────────

local BASE = "C:/ProgramData/MA Lighting Technologies/grandma/gma2_V_3.9.60"
eq(M.sibling_path(BASE, "3.3.4"),
   "C:/ProgramData/MA Lighting Technologies/grandma/gma2_V_3.3.4",
   "version segment substituted")

-- Only the last version-looking run is replaced; a show folder may hold a date.
eq(M.sibling_path("D:/shows/2026.01.09/grandma/gma2_V_3.9.60", "3.3.4"),
   "D:/shows/2026.01.09/grandma/gma2_V_3.3.4",
   "earlier dotted run left alone")
eq(M.sibling_path("C:/no/version/here", "3.3.4"), nil, "no version segment")
eq(M.sibling_path(BASE, "bad"), nil, "bad target rejected")
eq(M.sibling_path(nil, "3.3.4"), nil, "nil base rejected")

local c = M.candidates("Sequence")
eq(#c, 3, "three folders searched")
eq(c[1], "/importexport/Sequence.xml", "importexport searched first")
eq(c[2], "/library/Sequence.xml", "library second")
eq(c[3], "/fixture_layers/Sequence.xml", "fixture_layers third")

-- ─── POOLS / export_cmd / plugin_descriptor ───────────────────

eq(#M.POOLS, 13, "thirteen pools, matching the old macro")
eq(M.POOLS[1].key, "fixturetype", "fixture types export first")
eq(M.POOLS[1].setup, 3, "fixture types live at setup number 3")
eq(M.POOLS[1].dir, "/library/", "fixture types land in library")
eq(M.POOLS[2].key, "fixturelayers", "fixture layers second")
eq(M.POOLS[2].setup, 4, "fixture layers at setup number 4")
eq(M.POOLS[2].dir, "/fixture_layers/", "layers land in fixture_layers")

local by_key = {}
for _, p in ipairs(M.POOLS) do by_key[p.key] = p end
eq(by_key.userimagepool.root, 8, "UserImagePool is Root 8")
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

-- Every pool needs exactly one addressing mode and a place to look for the file.
for _, p in ipairs(M.POOLS) do
    eq((p.root ~= nil) ~= (p.setup ~= nil), true, p.key .. " has exactly one address mode")
    eq(type(p.file), "string", p.key .. " names a file")
    eq(has(M.candidates(p.file)[1], p.file), true, p.key .. " file name is searchable")
end

eq(M.export_cmd(by_key.macros), 'Export Root 13 "Macros"/o', "root pool export")
eq(M.export_cmd(M.POOLS[2]), 'Export * "FixtureLayers"/o', "setup export uses *")

local desc = M.plugin_descriptor("3.3.4", "Downgrade Import.lua", "Downgrade Import")
eq(has(desc, 'major_vers="3" minor_vers="3" stream_vers="4"'), true,
   "descriptor carries the target version")
eq(has(desc, "xml/3.3.4/MA.xsd"), true, "descriptor schema url")
eq(has(desc, 'luafile="Downgrade Import.lua"'), true, "descriptor names the lua file")
eq(has(desc, 'name="Downgrade Import"'), true, "descriptor names the plugin")
eq(has(desc, '<?xml version="1.0" encoding="utf-8"?>'), true, "descriptor is well formed")
eq(M.plugin_descriptor("bad", "x.lua", "x"), nil, "bad version rejected")

-- A generated descriptor must survive its own rewrite check: the same four
-- fields the plugin looks for in an export are present here too.
local round = M.rewrite_header(desc, "3.9.60")
eq(has(round, 'minor_vers="9"'), true, "generated descriptor is itself rewritable")

-- ─── result ───────────────────────────────────────────────────

if fails == 0 then
    print("all downgrade-export logic tests passed")
else
    print(string.format("%d failure(s)", fails))
    os.exit(1)
end
