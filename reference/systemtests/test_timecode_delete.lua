--*******************************************************************************************
-- This script tests the methods to delete a timecode.
-- Timecode 6
--*******************************************************************************************

local test =
{
    method_name      = "DELETE";
    object_name      = "TIMECODE";
    pre              = 'ClearAll; delete timecode 6 /nc';
    steps =
    {
        {
            pre  = 'store tc 6';
            cmd  = 'delete tc 6 /nc';
            post = 'label tc 6 "DEL_TC_1"';
            cleanup = '';
            test = 6;
            gold = -1;
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