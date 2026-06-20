--*******************************************************************************************
-- This script tests the methods to 'go' a timecode.
-- Timecode 11
--*******************************************************************************************

local test =
{
    method_name      = "GO";
    object_name      = "TIMECODE";
    pre              = 'ClearAll; delete tc 11 /nc';
    steps =
    {
        {
            smoketest = true;
            pre  = 'store tc 11';
            cmd  = 'go tc 11';
            post = 'label tc 11 "GO_TC_1"';
            cleanup = 'off tc 11';
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