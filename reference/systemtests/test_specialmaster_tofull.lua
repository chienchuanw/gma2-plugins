--*******************************************************************************************
-- This script tests the method 'tofull' for a specialmaster.
-- 
--*******************************************************************************************

local test =
{
    method_name      = "TOFULL";
    object_name      = "SPECIALMASTER";
    pre              = 'ClearAll';

    steps =
    {
        {
            -- 'tofull' the grand master
            pre  = 'fixture thru at 45; sm 2.1 at 30';
            cmd  = 'tofull sm 2.1';
            post = '';
            cleanup	 = '';
            test_dmx = true;
            test = 178;
            gold = 878;
        },
        {
            smoketest = true;
            -- 'tofull' the 'program time'
            pre  = 'sm 2.2 at 1';
            cmd  = 'tofull sm 2.2';
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