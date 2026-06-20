--*******************************************************************************************
-- This script tests the methods to 'full' a presettype. 
-- DMXSnapshot 335-338
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "FULL";
    object_name      = "PRESETTYPE";
    pre              = 'ClearAll; delete dmxsnap 335+336 /nc';
    steps =
    {
        {
            -- presettype "dimmer" full
            pre  = 'fixture thru';
            cmd  = 'presettype dimmer full';
            post = 'label dmxsnap 335 "FUL_PRT_1"';
            cleanup = '';
            test_dmx    = true;
            test = 335;
            gold = 337;
        },
        {
            -- presettype "position" full
            pre  = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2] + fixturecount[3] .. ';';
            cmd  = 'presettype position full';
            post = 'label dmxsnap 336 "FUL_PRT_2"';
            cleanup = '';
            test_dmx    = true;
            test = 336;
            gold = 338;
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