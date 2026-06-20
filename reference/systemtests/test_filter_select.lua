--*******************************************************************************************
-- This script tests the method to select a filter.
--*******************************************************************************************

local test =
{
    method_name      = "SELECT";
    object_name      = "FILTER";
    pre              = 'ClearAll; delete filter 2 /nc';
    steps =
    {
        {
            smoketest = true;
            pre  = 'edit filter 2; edit filter 2'; -- open and close edit window
            cmd  = 'select filter 2'; -- filter 2 is green highlited
            post = 'label filter 2 "SEL_FIL_1" ';
            cleanup = 'select filter 1';
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