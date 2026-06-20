--*******************************************************************************************
-- This script tests the methods to 'toggle' a timecode.
-- Timecode 14
--*******************************************************************************************

local test =
{
    method_name      = "TOGGLE";
    object_name      = "TIMECODE";
    pre              = 'ClearAll; delete tc 14 /nc';
    steps =
    {
        {
            -- toggle on
            smoketest = true;
            pre  = 'store tc 14';
            cmd  = 'toggle tc 14';
            post = 'label tc 14 "TOG_TC_1"';
            cleanup = 'off tc 14';
        },
        {
            -- toggle off
            smoketest = true;
            pre  = 'on tc 14';
            cmd  = 'toggle tc 14';
            post = 'label tc 14 "TOG_TC_1"';
            cleanup = 'off tc 14';
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