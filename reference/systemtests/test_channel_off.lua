--*******************************************************************************************
-- This script tests to off a channel 
-- DmxSnap 31
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "OFF";
    object_name      = "CHANNEL";
    pre              = 'ClearAll; delete DMXsnapshot 31 /nc';
   
    steps =
    {
        {
            pre  = 'Channel 1 thru ' .. math.floor(fixturecount[1]/2) .. ' at 100';
            cmd  = 'Off Channel ' .. math.floor(fixturecount[1]/4);
            post = 'label DmxSnapshot 31 "OFF_CH_1"';
            cleanup = '';
            test_dmx = true;
            test = 31;
            gold = 531;
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