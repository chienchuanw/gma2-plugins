--*******************************************************************************************
-- This script tests the methods to 'top' a timecode.
-- Timecode 15
--*******************************************************************************************

local test =
{
    method_name      = "TOP";
    object_name      = "TIMECODE";
    pre              = 'ClearAll; delete tc 15 /nc';
    steps =
    {
        {
            smoketest = true;
            pre  = 'store tc 15';
            cmd  = 'top tc 15';
            post = 'label tc 15 "TOP_TC_1"';
            cleanup = '';
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