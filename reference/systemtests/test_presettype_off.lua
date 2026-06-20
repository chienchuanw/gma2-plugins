--*******************************************************************************************
-- This script tests the methods to 'off' a presettype. 
-- DMXSnapshot 339-342
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "OFF";
    object_name      = "PRESETTYPE";
    pre              = 'ClearAll; delete dmxsnap 339 /nc';
    steps =
    {
        {
            -- off presettype focus
            pre  = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2] + fixturecount[3] .. '; presettype dimmer full; presettype focus full';
            cmd  = 'off presettype focus'; -- focus back on default
            post = 'label dmxsnap 339 "OFF_PRT_1"';
            cleanup = '';
            test_dmx = true;
            test = 339;
            gold = 341;
        },
        {
            -- off presettype thru
            pre  = 'fixture thru; presettype dimmer at 0 thru 100 thru 42; presettype gobo at 42; presettype position full';
            cmd  = 'off presettype thru';
            post = 'label dmxsnap 340 "OFF_PRT_2"';
            cleanup = '';
            test_dmx = true;
            test = 340;
            gold = 342;
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