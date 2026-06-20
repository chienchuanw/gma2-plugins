--*******************************************************************************************
-- This script tests the method to make a specialmaster on.
-- 
--*******************************************************************************************

local test =
{
    method_name      = "ON";
    object_name      = "SPECIALMASTER";
    pre              = 'ClearAll';

    steps =
    {
        {
            -- make sm 2.3 ('Exec Time') on
            smoketest = true;
            pre  = '';
            cmd  = 'on sm 2.3';
            post = '';
            cleanup	 = 'off sm 2.3';
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