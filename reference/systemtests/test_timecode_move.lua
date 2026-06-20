--*******************************************************************************************
-- This script tests the methods to copy a timecode.
-- Timecode 9+10
--*******************************************************************************************

local test =
{
    method_name      = "MOVE";
    object_name      = "TIMECODE";
    pre              = 'ClearAll; delete tc 9 + 10 /nc';
    steps =
    {
        {
            smoketest = true;
            pre  = 'store tc 9';
            cmd  = 'move tc 9 at 10 /nc';
            post = 'label tc 10 "MOV_TC_1"';
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