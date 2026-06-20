--*******************************************************************************************
-- This script tests the methods to 'on' a presettype. 
-- DMXSnapshot 343, Seq 195
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "ON";
    object_name      = "PRESETTYPE";
    pre              = 'ClearAll; delete dmxsnap 343 /nc; delete seq 195 /nc';
    steps =
    {
        {
            -- on presettype dimmer
            pre  = 'fixture thru at 97; store seq 195 /nc; clearall; fixture thru;';
            cmd  = 'on presettype dimmer; store seq 195 /o; clearall; go seq 195';
            post = 'label dmxsnap 343 "ON_PRT_1"; label seq 195 "ON_PRT_1"';
            cleanup = '';
            test_dmx = true;
            test = 343;
            gold = 344;
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