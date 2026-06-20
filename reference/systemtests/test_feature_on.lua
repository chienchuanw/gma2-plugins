--*******************************************************************************************
-- This script tests the method on to a feature.
-- DmxSnap 214
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "ON";
    object_name      = "FEATURE";
    pre              = 'ClearAll; delete DmxSnapshot 214 /nc';
    steps =
    {
        {
            pre  = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 55'; --must have feature position
            cmd  = 'on feature position'; --moving to center
            post = 'label DmxSnapshot 214 "ON_FEA_1" ';
            cleanup = '';
            test_dmx = true;
            test = 214;
            gold = 714;
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