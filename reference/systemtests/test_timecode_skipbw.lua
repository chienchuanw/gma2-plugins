--*******************************************************************************************
-- This script tests the methods to 'skipbw' (<<<) a timecode.
-- Timecode 20
--*******************************************************************************************

local test =
{
    method_name      = "SKIPBW";
    object_name      = "TIMECODE";
    pre              = 'ClearAll; delete tc 20 /nc';
    steps =
    {
        {
            smoketest = true;
            pre  = 'store tc 20; go tc 20';
            cmd  = '<<< tc 20';
            post = 'label tc 20 "SKB_TC_1"';
            cleanup = 'off tc 20';
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