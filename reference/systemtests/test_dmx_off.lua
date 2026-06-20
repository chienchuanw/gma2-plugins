--*******************************************************************************************
-- This script tests the method off to a dmx-value. For the GMA DMX Tester Output 
-- The dmx tester has highest priority. Make sure to reset!!
-- DmxSnap 82
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "OFF";
    object_name      = "DMX";
    pre              = 'ClearAll; delete DmxSnapshot 82 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'DMX 1.1 thru 1.' .. fixturecount[1] .. ' at 0 thru 100';
            cmd  = 'Off DMX 1.1 thru 1.' .. fixturecount[1];
            post = 'label DmxSnapshot 82 "OFF_DMX"';
            cleanup = '';
            test_dmx = true;
            test = 82;
            gold = 582;
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