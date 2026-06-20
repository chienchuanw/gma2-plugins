--*******************************************************************************************
-- This script tests the method to unpark a selection. 
-- DmxSnap 431
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "UNPARK";
    object_name      = "SELECTION";
    pre              = 'ClearAll; delete DmxSnapshot 431 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2]+fixturecount[3] .. ' at 100; park selection; at 50';
            cmd  = 'unpark selection';
            post = 'label DmxSnapshot 431 "UNP_SELE_1"';
            cleanup = '';
            test_dmx = true;
            test = 431;
            gold = 731;
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