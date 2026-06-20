--*******************************************************************************************
-- This script tests the method to 'select' a timecode.
-- Timecode 21
--*******************************************************************************************

local test =
{
    method_name      = "SELECT";
    object_name      = "TIMECODE";
    pre              = 'ClearAll; delete tc 21 /nc';
    steps =
    {
        {
            smoketest = true;
            pre  = 'store tc 21';
            cmd  = 'select tc 21';
            post = 'label tc 21 "SEL_TC_1"';
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