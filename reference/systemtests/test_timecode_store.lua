--*******************************************************************************************
-- This script tests the methods to store a timecode.
-- Timecode 5
--*******************************************************************************************

local test =
{
    method_name      = "STORE";
    object_name      = "TIMECODE";
    pre              = 'ClearAll; delete timecode 5 /nc';
    steps =
    {
        {
            smoketest = true;
            pre  = '';
            cmd  = 'store tc 5 /nc';
            post = 'label tc 5 "STO_TC_1"';
            cleanup = '';
            -- test = 5;
            -- gold = 105;
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