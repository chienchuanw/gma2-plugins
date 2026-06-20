--*******************************************************************************************
-- This script tests the method selfix to a dmx-value. 
-- The dmx tester has highest priority. Make sure to reset!!
-- DmxSnap 84
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "SELFIX";
    object_name      = "DMX";
    pre              = 'ClearAll; delete DmxSnapshot 84 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre = 'DMX 1.1 thru 1.' .. fixturecount[1] .. ' at 0 thru 89';
            cmd  = 'Selfix DMX 1.1 thru 1.' .. fixturecount[1] .. '; at 0 thru 100';
            post = 'label DmxSnapshot 84 "SELF_DMX"';
            cleanup = '';
            test_dmx = true;
            test = 84;
            gold = 584;
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