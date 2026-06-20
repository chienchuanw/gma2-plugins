--*******************************************************************************************
-- This script tests the method at to a dmx-value. For the GMA DMX Tester Output 
-- The dmx tester has highest priority. Make sure to reset!!
-- DmxSnap 80
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "AT";
    object_name      = "DMX";
    pre              = 'ClearAll; delete DmxSnapshot 80 /nc';
    version_script   = '3.2.80.0';
   
    steps =
    {
        {
            cmd  = 'DMX 1.1 thru 1.' .. fixturecount[1] .. ' at 0 thru 100';
            post = 'label DmxSnapshot 80 "AT_DMX"';
            cleanup = '';
            test_dmx = true;
            test = 80;
            gold = 580;
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