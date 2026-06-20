--*******************************************************************************************
-- This script tests the methods to 'insert' a timecode.
-- Timecode 16+17
--*******************************************************************************************

local test =
{
    method_name      = "INSERT";
    object_name      = "TIMECODE";
    pre              = 'ClearAll; delete tc 16+17 /nc';
    steps =
    {
        {
            smoketest = true;
            pre  = 'store tc 16; store tc 17';
            cmd  = 'insert tc 17 at 16';
            post = 'label tc 16+17 "INS_TC_1"';
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