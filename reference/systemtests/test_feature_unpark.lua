--*******************************************************************************************
-- This script tests the method unpark to a feature.
-- DmxSnap 217
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "UNPARK";
    object_name      = "FEATURE";
    pre              = 'ClearAll; delete DmxSnapshot 217 /nc';
    steps =
    {
        {
            pre  = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 100; feature gobo2 at 50; park feature gobo2';
            cmd  = 'unpark feature gobo2; feature gobo2 at 100';
            post = 'label DmxSnapshot 217 "UNP_FEA_1" ';
            cleanup= 'unpark feature gobo2';
            test_dmx = true;
            test = 217;
            gold = 717;
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