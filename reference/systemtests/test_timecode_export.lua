--*******************************************************************************************
-- This script tests the method to 'export' a timecode.
-- Timecode 22+23
--*******************************************************************************************

local test =
{
    method_name      = "EXPORT";
    object_name      = "TIMECODE";
    pre              = 'ClearAll; delete tc 22 + 23 /nc';
    steps =
    {
        {
            smoketest = true;
            pre  = 'store tc 22';
            cmd  = 'export tc 22 "export_timecode.xml" /nc';
            post = 'label tc 22 "EXP_TC_1"';
            cleanup = '';
        },
        {
            smoketest = true;
            pre  = '';
            cmd  = 'import "export_timecode.xml" at tc 23 /nc';
            post = 'label tc 23 "EXP_TC_2"';
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