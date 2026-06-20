--*******************************************************************************************
-- This script tests the methods to 'pause' a timecode.
-- Timecode 18
--*******************************************************************************************

local test =
{
    method_name      = "PAUSE";
    object_name      = "TIMECODE";
    pre              = 'ClearAll; delete tc 18 /nc';
    steps =
    {
        {
            -- toggle on
            smoketest = true;
            pre  = 'store tc 18; go tc 18';
            cmd  = 'pause tc 18';
            post = 'label tc 18 "PAU_TC_1"';
            cleanup = 'off tc 18';
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