--*******************************************************************************************
-- This script tests the method to oops a selection. 
-- DmxSnap 426
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "OOPS";
    object_name      = "SELECTION";
    pre              = 'ClearAll; delete DmxSnapshot 426/nc; highlight on; Fixture 1 thru ' .. fixturecount[2];
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2]+fixturecount[3];
            cmd  = 'oops selection';
            post = 'label DmxSnapshot 426 "OOPS_SELE_1"';
            cleanup = 'highlight off';
            test_dmx = true;
            test = 426;
            gold = 726;
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