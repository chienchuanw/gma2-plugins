--*******************************************************************************************
-- This script tests to full a channel 
-- DmxSnap 28
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "FULL";
    object_name      = "CHANNEL";
    pre              = 'ClearAll; delete DmxSnapshot 28 /nc';
   
    steps =
    {
        {
            cmd  = 'Channel 1 full';
            post = 'label DmxSnapshot 28 "FULL_CH_1"';
            cleanup = '';
            test_dmx = true;
            test = 28;
            gold = 528;
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