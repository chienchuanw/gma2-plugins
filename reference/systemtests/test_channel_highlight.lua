--*******************************************************************************************
-- This script tests the method highlight to a channel 
-- DmxSnap 29+30
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "HIGHLIGHT";
    object_name      = "CHANNEL";
    pre              = 'ClearAll; delete DmxSnapshot 29 + 30 /nc; highlight off';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'Channel 1 thru ' .. fixturecount[1];
            cmd  = 'highlight on';
            post = 'label DmxSnapshot 29 "HILI_CH_1"';
            cleanup = '';
            test_dmx = true;
            test = 29;
            gold = 529;
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