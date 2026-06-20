--*******************************************************************************************
-- This script tests the methods to park a dmx-value. For the GMA DMX Tester Output 
-- The dmx tester has highest priority. Make sure to reset!!
-- DmxSnap 83
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "PARK";
    object_name      = "DMX";
    pre              = 'ClearAll; delete DmxSnapshot 83 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'DMX 1.1 thru 1.' .. fixturecount[1] .. ' at 0 thru 100';
            cmd  = 'Park DMX 1.1 thru 1.' .. fixturecount[1] .. '; Channel 1 thru ' .. fixturecount[1] .. ' at 100';
            post = 'label DmxSnapshot 83 "PARK_DMX"';
            cleanup = '';
            test_dmx = true;
            test = 83;
            gold = 583;
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