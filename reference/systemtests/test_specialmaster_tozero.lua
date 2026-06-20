--*******************************************************************************************
-- This script tests the method 'tozero' for a specialmaster.
-- 
--*******************************************************************************************

local test =
{
    method_name      = "TOZERO";
    object_name      = "SPECIALMASTER";
    pre              = 'ClearAll';

    steps =
    {
        {
            -- 'tozero' the grand master
            pre  = 'fixture thru at 45; sm 2.1 at 30';
            cmd  = 'tozero sm 2.1';
            post = '';
            cleanup	 = 'tofull sm 2.1';
            test_dmx = true;
            test = 179;
            gold = 879;
        },
        {
            smoketest = true;
            -- 'tozero' the 'program time'
            pre  = 'sm 2.2 at 1';
            cmd  = 'tozero sm 2.2';
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