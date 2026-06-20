--*******************************************************************************************
-- This script tests the method highlight to a fixture 
-- DmxSnap 247+248
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "HIGHLIGHT";
    object_name      = "FIXTURE";
    pre              = 'ClearAll; highlight off; delete DmxSnapshot 247+248 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2];
            cmd  = 'highlight on';
            post = 'label DmxSnapshot 247 "HILI_FIX_1"';
            cleanup = '';
            test_dmx = true;
            test = 247;
            gold = 747;
        },
        {
            pre  = 'highlight off; Fixture 1 thru ' .. fixturecount[2]+fixturecount[3];
            cmd  = 'highlight on';
            post = 'label DmxSnapshot 248 "HILI_FIX_2"';
            cleanup = 'highlight off';
            test_dmx = true;
            test = 248;
            gold = 748;
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