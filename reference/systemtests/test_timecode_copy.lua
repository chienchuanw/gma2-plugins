--*******************************************************************************************
-- This script tests the methods to copy a timecode.
-- Timecode 7+8
--*******************************************************************************************

local test =
{
    method_name      = "COPY";
    object_name      = "TIMECODE";
    pre              = 'ClearAll; delete tc 7 + 8 /nc';
    steps =
    {
        {
            smoketest = true;
            pre  = 'store tc 7';
            cmd  = 'copy tc 7 at 8 /nc';
            post = 'label tc 7+8 "COP_TC_1"';
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