--*******************************************************************************************
-- This script tests to on a channel 
-- DmxSnap 32
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "ON";
    object_name      = "CHANNEL";
    pre              = 'ClearAll; delete DmxSnapshot 32 /nc';
   
    steps =
    {
        {
            pre = 'channel 1 at 45; off channel 1';
            cmd  = 'on Channel 1'; 
            post = 'label DmxSnapshot 32 "ON_CH_1"';
            cleanup = '';
            test_dmx = true;
            test = 32;
            gold = 532;
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