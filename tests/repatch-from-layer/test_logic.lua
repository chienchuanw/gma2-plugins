-- run from repo root:  lua tests/repatch-from-layer/test_logic.lua
--
-- The centrepiece is the golden test: fixtures/single-instance.xml is a
-- de-identified slice of a real console layer export, and fixtures/golden-lines.txt
-- holds the patch commands GMA Toolbox generated for those same fixtures. Both
-- describe the same rig from opposite directions, so parsing one and emitting
-- the other must reproduce the file byte for byte.

local PLUGIN = "plugins/repatch-from-layer/Repatch From Layer.lua"
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

local FIX = "tests/repatch-from-layer/fixtures/"

-- ─── decode_address ───────────────────────────────────────────

eq(M.decode_address(1), "1.001", "first channel of universe 1")
eq(M.decode_address(512), "1.512", "last channel of universe 1")
eq(M.decode_address(513), "2.001", "first channel of universe 2")
eq(M.decode_address(51201), "101.001", "AECO 20 start address")
eq(M.decode_address(55127), "108.343", "TB5 201 start address")
eq(M.decode_address(0), nil, "address 0 means unpatched")
eq(M.decode_address(nil), nil, "nil address")

local _, u, a = M.decode_address(55127)
eq(u, 108, "universe component")
eq(a, 343, "address component")

-- ─── parse_layer: single-instance export ──────────────────────

local single = M.parse_layer(slurp(FIX .. "single-instance.xml"))
eq(#single, 10, "10 fixtures parsed")
eq(single[1].id, 101, "first fixture id")
eq(single[1].instances, 1, "single-instance fixture has one subfixture")
eq(single[1].start, 51201, "start address of fixture 101")
eq(single[1].multibreak, false, "single break")
eq(single[1].zeros, 0, "no unpatched subfixtures")
eq(single[1].layer, "TEST SINGLE", "layer name captured")
eq(single[1].pos ~= nil, true, "position parsed for a future position plugin")

-- ─── golden test: parsed XML reproduces the Toolbox macro ─────

local golden = {}
for line in slurp(FIX .. "golden-lines.txt"):gmatch("[^\n]+") do
    golden[#golden + 1] = line
end
eq(#golden, 10, "10 golden lines")

local usable = M.classify(single)
local produced = M.repatch_lines(usable)
eq(#produced, #golden, "line count matches the Toolbox macro")
for i = 1, math.max(#produced, #golden) do
    eq(produced[i], golden[i], "golden line " .. i)
end

-- ─── parse_layer: multi-instance (TB5) export ─────────────────

local multi = M.parse_layer(slurp(FIX .. "multi-instance.xml"))
eq(#multi, 3, "3 multi-instance fixtures parsed")
eq(multi[1].id, 201, "first TB5 id")
eq(multi[1].instances, 11, "TB5 has 11 subfixtures")
eq(#multi[1].addresses, 11, "one address per subfixture")
eq(multi[1].multibreak, false, "11 subfixtures is not multi-break")

-- The start address is the smallest address, NOT the first subfixture's:
-- <SubFixture index="0"> of TB5 201 sits at 55191, nine slots up from the start.
eq(multi[1].addresses[1], 55191, "subfixture index 0 is not the lowest address")
eq(multi[1].start, 55127, "start is the minimum address")

local multi_usable = M.classify(multi)
eq(#multi_usable, 3, "all three TB5s are repatchable")
eq(M.repatch_lines(multi_usable)[1], "Assign Fixture 201 At Dmx 108.343",
   "one line rebuilds all 11 instances")
eq(M.repatch_lines(multi_usable)[3], "Assign Fixture 203 At Dmx 109.001",
   "third TB5 crosses into universe 109")

-- ─── classify: unpatched and multi-break ──────────────────────

local SYNTHETIC = [[
<MA>
<Layer index="0" name="SYN">
<Fixture index="0" name="Unpatched" fixture_id="900">
  <SubFixture index="0"><Patch><Address>0</Address></Patch></SubFixture>
</Fixture>
<Fixture index="1" name="TwoBreaks" fixture_id="901">
  <SubFixture index="0"><Patch><Address>100</Address><Address>2000</Address></Patch></SubFixture>
</Fixture>
<Fixture index="2" name="Normal" fixture_id="902">
  <SubFixture index="0"><Patch><Address>600</Address></Patch></SubFixture>
</Fixture>
<Fixture index="3" name="PartlyPatched" fixture_id="903">
  <SubFixture index="0"><Patch><Address>0</Address></Patch></SubFixture>
  <SubFixture index="1"><Patch><Address>700</Address></Patch></SubFixture>
</Fixture>
</Layer>
</MA>]]

local syn = M.parse_layer(SYNTHETIC)
eq(#syn, 4, "4 synthetic fixtures")

local ok_list, unpatched, multibreak = M.classify(syn)
eq(#ok_list, 2, "two repatchable")
eq(#unpatched, 1, "one fully unpatched")
eq(#multibreak, 1, "one multi-break")
eq(unpatched[1].id, 900, "900 is the unpatched one")
eq(multibreak[1].id, 901, "901 is the multi-break one")
eq(ok_list[1].id, 902, "902 is repatchable")
eq(ok_list[2].start, 700, "903 starts at its only real address, ignoring the 0")
eq(ok_list[2].zeros, 1, "903 records its unpatched subfixture")

-- ─── merge ────────────────────────────────────────────────────

local merged, dupes = M.merge({ syn, single })
eq(#merged, 14, "merged list holds every distinct fixture")
eq(dupes, 0, "no duplicates across different layers")
eq(merged[1].id, 101, "merged list is sorted by fixture id")

local _, dupes2 = M.merge({ single, single })
eq(dupes2, 10, "re-reading the same layer is counted as duplicates")

-- ─── restore_lines ────────────────────────────────────────────

local restore, skipped, unpatches = M.restore_lines(
    { { id = 101, start = 1 }, { id = 102, start = 55127 }, { id = 103, start = 600 } },
    { [101] = "1.001", [102] = "(-)" })          -- 103 absent from this console
eq(#restore, 2, "a line for the patched fixture and for the unpatched one")
eq(restore[1], "Assign Fixture 101 At Dmx 1.001", "patched fixture is reassigned")
eq(restore[2], "Delete Dmx 108.343 /nc",
   "unpatched fixture is undone by deleting the address repatch will use")
eq(unpatches, 1, "one restore line unpatches")
eq(#skipped, 1, "only the fixture missing from this console is skipped")
eq(skipped[1].id, 103, "103 is the one with no state here")

eq(M.unpatch_line("12.007", 55), string.format(M.UNPATCH_FORMAT, "12.007", 55),
   "unpatch line follows the configured format")

eq(M.macro_base("NEW_PATCH_MYSHOW"), "MYSHOW", "macro names drop the file prefix")
eq(M.macro_base("MYSHOW"), "MYSHOW", "a name without the prefix is left alone")

-- ─── macro_xml ────────────────────────────────────────────────

local xml = M.macro_xml({
    { name = "T & <est>", info = "info", lines = { "Assign Fixture 1 At Dmx 1.001" } },
    { name = "second", lines = {} },
})
eq(xml:find('<Macro index="0" name="T &amp; &lt;est&gt;">', 1, true) ~= nil, true,
   "macro name is XML-escaped")
eq(xml:find('<Macro index="1" name="second">', 1, true) ~= nil, true,
   "second macro gets index 1")
eq(xml:find('<Macroline index="0" delay="0.01"><text>Menu On &quot;CommandlineResponse&quot;</text></Macroline>',
   1, true) ~= nil, true, "leading Menu On line, quotes escaped")
eq(xml:find('<Macroline index="1" delay="0.01"><text>Assign Fixture 1 At Dmx 1.001</text></Macroline>',
   1, true) ~= nil, true, "command line follows the header")
eq(xml:find('<Macroline index="2" delay="0.01"><text>Menu Off &quot;CommandlineResponse&quot;</text></Macroline>',
   1, true) ~= nil, true, "trailing Menu Off line")
eq(xml:find("3.9.60/MA.xsd", 1, true) ~= nil, true, "targets the 3.9.60 schema")
eq(select(2, xml:gsub("<Macroline", "")), 5, "1 command + 2 wrappers, plus 2 wrappers for the empty macro")

-- ─── name handling ────────────────────────────────────────────

eq(M.clean_name("  (LYI) TB5.xml "), "(LYI) TB5", "trims and drops the extension")
eq(M.clean_name("name.XML"), "name", "extension match is case-insensitive")
eq(M.clean_name("a/b"), nil, "rejects a path separator")
eq(M.clean_name("..\\evil"), nil, "rejects traversal")

eq(M.OUTPUT_PREFIX, "NEW_PATCH_", "generated-output prefix")
eq(M.default_output_name("SHOW-LAYER-"), "NEW_PATCH_SHOW", "prefix loses its LAYER tail")
eq(M.default_output_name("(LYI) TB5"), "NEW_PATCH_(LYI) TB5", "plain name keeps its shape")
eq(M.default_output_name("MYSHOW_layer_"), "NEW_PATCH_MYSHOW", "LAYER match is case-insensitive")

-- ─── xml_escape ───────────────────────────────────────────────

eq(M.xml_escape([[a & b < c > d " e ' f]]),
   "a &amp; b &lt; c &gt; d &quot; e &apos; f", "all five entities")
eq(M.xml_escape(nil), "", "nil escapes to empty")

if fails == 0 then print("ALL TESTS PASSED") else print(fails .. " FAILURE(S)"); os.exit(1) end
