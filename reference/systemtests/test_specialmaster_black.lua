--*******************************************************************************************
-- This script tests the methods 'black' for a specialmaster. 
-- DmxSnapshot 173+174, 873+874
--*******************************************************************************************

local test =
{
    method_name      = "BLACK";
    object_name      = "SPECIALMASTER";
    pre              = 'ClearAll';

    steps =
    {
        {
            -- black on grandmaster
            pre  = 'channel thru at 100; sm 2.1 at 30';
            cmd  = 'black on sm 2.1';
            post = '';
            cleanup	 = 'black off sm 2.1; sm 2.1 full';
            test_dmx = true;
            test = 173;
            gold = 873;
        },
        {
            -- black off grandmaster
            pre  = 'channel thru at 100; sm 2.1 at 30; black sm 2.1';
            cmd  = 'black off sm 2.1';
            post = '';
            cleanup	 = 'sm 2.1 full';
            test_dmx = true;
            test = 174;
            gold = 874;
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