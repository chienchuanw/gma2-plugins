--*******************************************************************************************
-- This script tests the method park to a feature.
-- Sequ 113, DmxSnap 215
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "PARK";
    object_name      = "FEATURE";
    pre              = 'ClearAll; delete DmxSnapshot 215 /nc; delete sequence 113 /nc';
    steps =
    {
        {
            pre  = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 80; feature beam1 at 75; store sequence 113 cue 1;';
            cmd  = 'park feature beam1; feature beam1 at 67; store sequence 113 cue 2; ClearAll; goto sequence 113 cue 2';
            post = 'label DmxSnapshot 215 "PARK_FEA_1"';
            cleanup= 'unpark feature beam1';
            test_dmx = true;
            test = 215;
            gold = 715;
        }
    };
};

RegisterTestScript(test);

--*******************************************************************************************
-- module entry point
--*******************************************************************************************

local function StartThisTest()
    StartSingleTestScript(test);
end

return StartThisTest;