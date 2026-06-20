--*******************************************************************************************
-- This script tests the methods to 'full' a specialmaster. 
-- DmxSnapshot 177, DmxSnapshot 877
--*******************************************************************************************

local test =
{
    method_name      = "FULL";
    object_name      = "SPECIALMASTER";
    pre              = 'ClearAll';

    steps =
    {
        {
            -- full grandmaster
            pre  = 'channel thru at 100; sm 2.1 at 30';
            cmd  = 'sm 2.1 full';
            post = '';
            cleanup	 = '';
            test_dmx = true;
            test = 177;
            gold = 877;
        },
        {
            -- full sm 3.2 ('Speed 2')
            smoketest = true;
            pre  = 'sm 3.2 at 2'; -- 2 BPM
            cmd  = 'sm 3.2 full'; -- 100 BPM
            post = '';
            cleanup	 = '';
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