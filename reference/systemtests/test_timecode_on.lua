--*******************************************************************************************
-- This script tests the methods to 'on' a timecode.
-- Timecode 12
--*******************************************************************************************

local test =
{
    method_name      = "ON";
    object_name      = "TIMECODE";
    pre              = 'ClearAll; delete tc 12 /nc';
    steps =
    {
        {
            smoketest = true;
            pre  = 'store tc 12';
            cmd  = 'on tc 12';
            post = 'label tc 12 "ON_TC_1"';
            cleanup = 'off tc 12';
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