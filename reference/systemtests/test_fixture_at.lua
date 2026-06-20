--*******************************************************************************************
-- This script tests the method at to a fixture 
-- DmxSnap 243
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "AT";
    object_name      = "FIXTURE";
    pre              = 'ClearAll; delete DmxSnapshot 243 /nc';
   
    steps =
    {
        {
            pre  = 'Fixture 1 at 100';
            cmd  = 'Fixture 2 thru ' .. fixturecount[2] .. ' at Fixture 1';
            post = 'label DmxSnapshot 243 "AT_FIX_1"';
            cleanup = '';
            test_dmx = true;
            test = 243;
            gold = 743;
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