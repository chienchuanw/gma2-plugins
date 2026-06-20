--*******************************************************************************************
-- This script tests the methods to 'at' a presettype. 
-- DMXSnapshot 331-334
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "AT";
    object_name      = "PRESETTYPE";
    pre              = 'ClearAll; delete dmxsnap 331 + 332 /nc';
    steps =
    {
        {
            -- select moving heads, presettype position at 42
            pre  = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2] + fixturecount[3] .. ';';
            cmd  = 'presettype position at 42';
            post = 'label dmxsnap 331 "AT_PRT_1"';
            cleanup = '';
            test_dmx    = true;
            test = 331;
            gold = 333;
        },
        {
            -- select moving heads, presettype position at 0 thru 42 thru 0
            pre  = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2] + fixturecount[3] .. ';';
            cmd  = 'presettype position at 0 thru 42 thru 0';
            post = 'label dmxsnap 332 "AT_PRT_2"';
            cleanup = '';
            test_dmx    = true;
            test = 332;
            gold = 334;
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