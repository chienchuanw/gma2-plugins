--*******************************************************************************************
-- This script tests the methods 'at' for a specialmaster. 
-- DmxSnapshot 172+872
--*******************************************************************************************

local test =
{
    method_name      = "AT";
    object_name      = "SPECIALMASTER";
    pre              = 'ClearAll';

    steps =
    {
        {
            -- grandmaster (sm 2.1) at 40
            pre  = 'channel thru at 50';
            cmd  = 'sm 2.1 at 40';
            post = '';
            cleanup	 = 'sm 2.1 full';
            test_dmx = true;
            test = 172;
            gold = 872;
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