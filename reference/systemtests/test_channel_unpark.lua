--*******************************************************************************************
-- This script tests to unpark a channel 
-- DmxSnap 35
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "UNPARK";
    object_name      = "CHANNEL";
    pre              = 'ClearAll; delete DmxSnapshot 35 /nc';
   
    steps =
    {
        {
            pre  = 'Channel 1 thru '.. fixturecount[1] ..' at 0 thru 100; Park channel 1 thru '.. fixturecount[1];
            cmd  = 'Unpark Channel 1 thru '..fixturecount[1]..'; Channel 1 thru '.. fixturecount[1] ..' at 100';
            post = 'label DmxSnapshot 35 "UNP_CH_1"';
            cleanup = '';
            test_dmx = true;
            test = 35;
            gold = 535;
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