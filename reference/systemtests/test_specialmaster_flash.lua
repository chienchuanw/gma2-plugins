--*******************************************************************************************
-- This script tests the methods to 'flash' a specialmaster. 
-- DmxSnapshot 175-176, DmxSnapshot 875-876
--*******************************************************************************************

local test =
{
    method_name      = "FLASH";
    object_name      = "SPECIALMASTER";
    pre              = 'ClearAll';

    steps =
    {
        {
            -- flash on grandmaster
            pre  = 'channel thru at 100; sm 2.1 at 30';
            cmd  = 'flash on sm 2.1';
            post = '';
            cleanup	 = 'flash off sm 2.1; sm 2.1 full';
            test_dmx = true;
            test = 175;
            gold = 875;
        },
        {
            -- flash off grandmaster
            pre  = 'channel thru at 100; sm 2.1 at 30; flash sm 2.1';
            cmd  = 'flash off sm 2.1';
            post = '';
            cleanup	 = 'sm 2.1 full';
            test_dmx = true;
            test = 176;
            gold = 876;
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