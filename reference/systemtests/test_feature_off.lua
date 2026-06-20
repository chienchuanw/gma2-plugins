--*******************************************************************************************
-- This script tests the method off to a feature.
-- DmxSnap 213
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "OFF";
    object_name      = "FEATURE";
    pre              = 'ClearAll; delete DmxSnapshot 213 /nc';
    steps =
    {
        {
            pre  = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 100; feature position at 45'; --must have feature position
            cmd  = 'off feature position';
            post = 'label DmxSnapshot 213 "OFF_FEA_1"';
            cleanup = '';
            test_dmx = true;
            test = 213;
            gold = 713;
        },
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