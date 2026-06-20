--*******************************************************************************************
-- This script tests to selfix a channel 
-- DmxSnap 34
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "SELFIX";
    object_name      = "CHANNEL";
    pre              = 'ClearAll; delete DmxSnapshot 34 /nc';
   
    steps =
    {
        {
            cmd  = 'Selfix Channel 1 at 100';
            post = 'label DmxSnapshot 34 "SELF_CH_1"';
            cleanup = '';
            test_dmx = true;
            test = 34;
            gold = 534;
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