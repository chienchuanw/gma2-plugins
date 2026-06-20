--*******************************************************************************************
-- This script tests the methods to unpark a dmx-value. For the GMA DMX Tester Output 
-- DmxSnap 85
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "UNPARK";
    object_name      = "DMX";
    pre              = 'ClearAll; delete DmxSnapshot 85 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'Park DMX 1.1 thru 1.' .. fixturecount[1];
            cmd  = 'DMX 1.1 thru 1.' .. fixturecount[1] .. ' at 0 thru 100; Unpark DMX 1.1 thru 1.' .. fixturecount[1];
            post = 'label DmxSnapshot 85 "UNP_DMX"';
            cleanup = '';
            test_dmx = true;
            test = 85;
            gold = 585;
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