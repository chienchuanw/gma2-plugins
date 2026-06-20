--*******************************************************************************************
-- This script tests the method to make a specialmaster off.
-- 
--*******************************************************************************************

local test =
{
    method_name      = "OFF";
    object_name      = "SPECIALMASTER";
    pre              = 'ClearAll';

    steps =
    {
        {
            -- make sm 2.3 ('Exec Time') off
            smoketest = true;
            pre  = 'on sm 2.3';
            cmd  = 'off sm 2.3';
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