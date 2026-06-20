--*******************************************************************************************
-- This script tests the methods to 'off' a timecode.
-- Timecode 13
--*******************************************************************************************

local test =
{
    method_name      = "OFF";
    object_name      = "TIMECODE";
    pre              = 'ClearAll; delete tc 13 /nc';
    steps =
    {
        {
            smoketest = true;
            pre  = 'store tc 13; on tc 13';
            cmd  = 'off tc 13';
            post = 'label tc 13 "OFF_TC_1"';
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