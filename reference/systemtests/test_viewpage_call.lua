--*******************************************************************************************
-- This script shows up the methods to call a viewpage.
-- Viewpage 2
--*******************************************************************************************


local test =
{
    method_name      = "CALL";
    object_name      = "VIEWPAGE";
    pre              = 'ClearAll; viewpage 1';

    steps =
    {
        {
            smoketest = true;
            pre  = '';
            cmd  = 'call viewpage 2';
            post = '';
            cleanup = 'viewpage 1';
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