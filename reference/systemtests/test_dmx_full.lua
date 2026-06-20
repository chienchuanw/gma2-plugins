--*******************************************************************************************
-- This script tests the method full to a dmx-value. For the GMA DMX Tester Output 
-- The dmx tester has highest priority. Make sure to reset!!
-- DmxSnap 81
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "FULL";
    object_name      = "DMX";
    pre              = 'ClearAll; delete DmxSnapshot 81 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            cmd  = 'DMX 1.1 thru 1.' .. fixturecount[1]..' at FULL';
            post = 'label DmxSnapshot 81 "FULL_DMX"';
            cleanup = '';
            test_dmx = true;
            test = 81;
            gold = 581;
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