--*******************************************************************************************
-- This script tests the method 'rate1' for a specialmaster.
-- 
--*******************************************************************************************

local test =
{
    method_name      = "RATE1";
    object_name      = "SPECIALMASTER";
    pre              = 'ClearAll';

    steps =
    {
        {
            smoketest = true;
            pre  = 'sm 4.1 at 0';
            cmd  = 'rate1 sm 4.1';
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