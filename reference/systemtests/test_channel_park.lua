--*******************************************************************************************
-- This script tests to park a channel 
-- DmxSnap 33
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "PARK";
    object_name      = "CHANNEL";
    pre              = 'ClearAll; delete DmxSnapshot 33 /nc';
   
    steps =
    {
        {
            pre  = 'Channel 1 thru '.. fixturecount[1] ..' at 0 thru 100'; 
            cmd  = 'Park channel 1 thru  '.. fixturecount[1] ..' ; Channel 1 thru  '.. fixturecount[1] ..' at 100';
            post = 'label DmxSnapshot 33 "PARK_CH_1"';
            cleanup = '';
            test_dmx = true;
            test = 33;
            gold = 533;
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