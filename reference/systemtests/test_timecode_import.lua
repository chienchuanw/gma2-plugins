--*******************************************************************************************
-- This script tests the method to 'import' a timecode.
-- Timecode 25
--*******************************************************************************************

local test =
{
    method_name      = "IMPORT";
    object_name      = "TIMECODE";
    pre              = 'ClearAll; delete tc 25 /nc';
    steps =
    {
        {
            smoketest = true;
            pre  = '';
            cmd  = 'import "import-timecode.xml" at tc 25 /nc';
            post = 'label tc 25 "IMP_TC_1"';
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