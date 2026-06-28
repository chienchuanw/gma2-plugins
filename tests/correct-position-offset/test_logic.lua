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
