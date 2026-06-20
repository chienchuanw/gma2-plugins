--*******************************************************************************************
-- This script tests the methods to 'skipfw' (>>>) a timecode.
-- Timecode 19
--*******************************************************************************************

local test =
{
    method_name      = "SKIPFW";
    object_name      = "TIMECODE";
    pre              = 'ClearAll; delete tc 19 /nc';
    steps =
    {
        {
            smoketest = true;
            pre  = 'store tc 19; go tc 19';
            cmd  = '>>> tc 19';
            post = 'label tc 19 "SKF_TC_1"';
            cleanup = 'off tc 19';
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