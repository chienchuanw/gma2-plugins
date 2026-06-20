--*******************************************************************************************
-- This script tests the method at to a channel 
-- DmxSnap 22
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "AT";
    object_name      = "CHANNEL";
    pre              = 'ClearAll; delete DmxSnapshot 22 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'Channel 1 at 100';
            cmd  = 'Channel 2 thru ' .. fixturecount[1] .. ' at Channel 1';
            post = 'label DmxSnapshot 22 "AT_CH_1"';
            cleanup = '';
            test_dmx = true;
            test = 22;
            gold = 522;
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